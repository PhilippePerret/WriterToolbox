# encoding: UTF-8

class ::String
class << self
  # Méthode qui recherche où le fichier en traitement ici, qui
  # contient des questions de checkup (automatique), place
  # ses questions (le ou les fichiers checkup affichant) les
  # questions pour pouvoir forcer leur actualisation.
  #
  # La méthode détruit les fichier ERB semidyn des checkups et
  # retourne un lien dans le message pour afficher ces fichiers
  #
  # ATTENTION ! La méthode a besoin de $narration_current_page
  # qui est l'instance Cnarration::Page de la page traitée
  #
  # +options+
  #   :quiet      Si true, aucun message
  #
  def rechercher_fichier_checkup_with_question options = nil
    options ||= Hash::new
    ipage = $narration_current_page
    pbook = ipage.livre.folder_semidyn.expanded_path
    grep_cmd = "grep -r -F \"<!-- #{ipage.handler}\.erb -->\" #{pbook}"
    evaluation = `#{grep_cmd}`
    evaluation = evaluation.force_encoding('utf-8')
    liens = evaluation.split("\n").collect do |found|
      pfile   = found.split(':').first
      File.unlink(pfile) if File.exist?(pfile)
      handler = pfile.sub(/^#{pbook}\//,'')[0..-5]
      where = "handler = '#{handler}' AND livre_id = #{ipage.livre_id}"
      hpage = Cnarration::table_pages.select(where:where).values.first
      # Lien à retourner à mettre dans le message
      "#{hpage[:titre]}".in_a(href:"page/#{hpage[:id]}/show?in=cnarration", target:'_blank')
    end.join("<br />")
    unless options[:quiet]
      flash "Les fichiers checkup suivants sont à actualiser :<br>#{liens}"
    end
  end


  # Traitement particulier des questions de checkup dans
  # les pages de la collection Narration.
  #
  # Ces questions sont identifiées par la balise :
  #   CHECKUP[question|groupe]
  #
  # On laisse toujours une marque dans le fichier pour
  # pouvoir construire le fichier checkup de l'annexe
  # du livre, qui doit pour se construire récolter toutes
  # les questions de tous les fichiers.
  #
  REG_QUESTION_CHECKUP = /(^)?[^_]CHECKUP\[(.*?)(?:\|(.*?))?\]($)?/o
  def formate_balises_question_checkup_in code, options = nil
    options ||= Hash::new
    output_format = options[:format] || options[:output_format] || :html
    q_indice = 0

    code.gsub(REG_QUESTION_CHECKUP){
      first_chr = $1.freeze
      debut_n   = first_chr != nil
      fin_n     = $4 != nil
      isoled    = debut_n && fin_n
      groupe    = $3.freeze
      question  = $2.strip.freeze
      q_indice  += 1
      q_id      = "qckup#{$narration_page_id}-#{q_indice}"

      # debug "question : '#{question}' / groupe: '#{groupe}'"
      lineq = case output_format
      when :html
        repere = <<-HTML
  <!-- CHECKUP[#{$narration_page_id}|#{q_id}|#{question}|#{groupe}] -->
        HTML
        ancre = "<a name='#{q_id}'></a>"
        "#{ancre}#{repere}<span id='#{q_id}' class='qcheckup#{isoled ? ' iso' : ''}'>#{question}</span>"
      when :latex
        # Note : En Latex, puisque ces corrections arrivent AVANT
        # le traitement par Kramdown, il faut mettre du code qui
        # ne sera pas changé par Kramdown, d'où les crochets.
        # Note de note : le traitement doit se faire AVANT le traitement
        # de kramdown, sinon les | sont remplacés par des longtables
        # intempestives.
        "LABEL[#{q_id}]QUESTIONCHKP[#{question}]"
      end

      # Texte final
      (isoled ? "\n" : "") + lineq
    }
  end

  # Méthode qui place les questions de checkup à l'endroit de la
  # marque `PRINT_CHECKUP`.
  #
  # Cette méthode complexe n'est appelée que lorsqu'on trouve la
  # marque PRINT_CHECKUP dans un fichier Narration (ce qui ne devrait
  # survenir qu'avec un seul fichier) et qu'on la remplace par toutes
  # les questions récoltées dans les fichiers.
  #
  # L'attribut entre crochets après la marque détermine le "groupe"
  # de question. Une dernière marque PRINT_CHECKUP sans attribut
  # peut déterminer de mettre toutes les questions restantes. Dans le
  # cas contraire, une alerte est donnée.
  #
  REG_PRINT_CHECKUP  = /PRINT\\?_CHECKUP(?:\[(.*?)\])?/
  def formate_balises_print_checkup code, options = nil

    options ||= Hash::new

    # Le format de sortie pour lequel il faut faire le traitement.
    output_format = options[:format] || options[:output_format] || :html
    # On aura besoin plus bas de passer l'attribut options
    # à une méthode donc :
    options[:output_format] = output_format

    # Il faut peut être ajouter l'explication sur les
    # checkups
    explication_checkup = Cnarration::texte_type("explication_checkups", options)
    code = code.sub(/EXPLICATION\\?_CHECKUPS?/, explication_checkup)

    # Dans un premier temps on relève toutes les questions qui
    # sont disséminées dans tous les fichiers du livre.
    get_all_questions_in_book $narration_book_id

    # On met en forme le code
    # Il doit contenir des balises `PRINT_CHECKUP` qui permettent
    # de savoir où on doit placer le code. Un attribut entre
    # crochets permet de connaitre le groupe de questions à
    # mettre. Ce groupe se trouve en clé de @table_checkup qui
    # contient toutes les questions rassemblées.
    code.gsub!(REG_PRINT_CHECKUP){
      groupe = $1
      # S'il n'y a pas de groupes, il faut mettre toutes les
      # questions qui restent
      if groupe.nil?
        # Pour la marque PRINT_CHECKUP seule, sans argument
        # (on met toutes les questions)
        # @table_checkup.collect do |grp, arr_question|
        allq = String::new
        while grp_and_arr = @table_checkup.shift
          grp, arr_question = grp_and_arr
          allq << ul_questions_checkup(arr_question, grp)
        end
        allq
      else
        ul_questions_checkup(@table_checkup.delete(groupe), groupe, options)
      end
    }

    # Il peut arriver qu'il reste des questions ou des groupes
    # de question qui n'ont pas été inscrites. Donc on fait comme
    # si un groupe "Autres questions" existait et on les écrit
    # à la fin du code
    unless @table_checkup.empty?
      flash "Des groupes de questions checkup ne sont pas traités (#{@table_checkup.keys.pretty_join}), je les ai ajoutés à la fin dans une rubrique “Autres questions”. Si tu veux les placer à un endroit précis, utilise les balises `PRINT_CHECKUP[&lt;groupe&gt;]` et un titre au-dessus."
      code += "Autres questions".in_h2 + @table_checkup.collect do |grp, arr_questions|
          ul_questions_checkup(arr_questions, grp, options)
        end.join('')
    end

    return code
  end

  # Construit et retourne le code des questions +questions+
  # +questions+
  #     Array contenant des Hash contenant {:id, :question, :file}
  #     Où :
  #     :id         Identifiant de la question (p.e. `qchup12-5`)
  #     :question   La question
  #     :pid        Identifiant de la page narration
  #     :file       Le path relatif du fichier contenant la question
  # +groupe+
  #     {String} Optionnellement, le nom du groupe
  #
  def ul_questions_checkup questions, groupe = nil, options = nil
    return "" if questions.nil?
    options ||= Hash::new
    output_format = options[:output_format]

    # Liste des fichiers déjà mis en commentaire (ils servent à
    # savoir si le fichier doit être actualisé après modification
    # de la question ou du fichier la contenant)
    @files_checkups_traited ||= Hash::new

    # Boucle sur chaque question
    all_questions = questions.collect do |hquestion|

      # La marque pour savoir que le fichier de la question est
      # utilisé ici et que s'il a été modifié il faut modifier aussi
      # ce fichier
      mark_file = unless @files_checkups_traited.has_key?(hquestion[:file])
        @files_checkups_traited.merge!(hquestion[:file] => true)
        "<!-- #{hquestion[:file]} -->"
      else
        ""
      end

      lien_vers_question = case output_format
      when :latex
        " (\\ref{#{hquestion[:id]}})"
      else
        # Le lien pour rejoindre la question dans son fichier
        lien_vers_question = "-&gt;&nbsp;revoir".in_a(href:"page/#{hquestion[:pid]}/show?in=cnarration##{hquestion[:id]}", target:"_blank")
        " (#{lien_vers_question})"
      end

      # Mise en forme de la question affichée dans le checkup
      case output_format
      when :latex
        "\\item #{hquestion[:question]} #{lien_vers_question}"
      else
        (
          hquestion[:question] +
          mark_file +
          lien_vers_question
        ).in_li(id: hquestion[:id])
      end
    end

    case output_format
    when :latex
      "\\begin{itemize}\n" +
      all_questions.join("\n") + "\n" +
      "\\end{itemize}"
    else
      all_questions.join('').in_ul(
        id:     "checkup_groupe_#{groupe || '__autre__'}",
        class:  'checkup_groupe'
      )
    end
  end

  # Méthode qui relève toutes les questions dans le livre
  # d'identifiant +livre_id+
  #
  # Produit un Hash qui contient en clé le nom du groupe
  # de la question et en valeur un Array qui contient
  # un hash par question trouvée qui contient :
  #   {id:"<id de la question>", question:"<la question>",
  #     file:"<path/relatif/to/the/file/from/book/folder.erb>"}
  # Cette table est placé dans `@table_checkup` qui est aussi
  # retourné à la méthode appelante.
  #

  # Pour chercher dans tous les fichiers du livre
  REG_CHECKUP_DATA = "grep -r '<!-- CHECKUP' %{book_folder}"
  # Pour relever fichier et question dans les résultats
  REG_BALISE_CHECKUP = /(.+?)<\!\-\- CHECKUP\[(.+?)\|(.+?)\|(.+?)\|(.*?)\] \-\->/

  def get_all_questions_in_book livre_id

    # La commande grep pour relever toutes les questions
    # dans tous fichiers du livre courant
    book_nfolder = Cnarration::LIVRES[$narration_book_id][:folder]
    book_pfolder = (Cnarration::folder_data_semidyn + book_nfolder).expanded_path
    grep_command = REG_CHECKUP_DATA % {book_folder: book_pfolder}

    # La table produite avec toutes les questions
    @table_checkup = Hash::new

    # === Recherche ===
    evaluation = `#{grep_command}`
    evaluation = evaluation.force_encoding('utf-8')

    evaluation.split("\n").each do |line|
      founds = line.scan(REG_BALISE_CHECKUP)
      # puts "founds (#{founds.count}): #{founds.inspect}"
      founds.each do |found|
        pfile, pid, qid, qcontent, qgroupe = found
        # qgroupe = "__autres__" if qgroupe.strip == ""
        qgroupe = qgroupe.nil_if_empty || "__autres__"
        pfile = pfile.split(':').first.sub(/^#{book_pfolder}\//o,'')

        # Si le groupe n'existe pas encore, il faut l'ajouter
        unless @table_checkup.has_key? qgroupe
          @table_checkup.merge!(qgroupe => Array::new)
        end
        # On peut maintenant ajouter la question
        @table_checkup[qgroupe] << {
          id: qid, question:qcontent, pid: pid.to_i, file:pfile
        }
        # debug "ID : #{qid} / QUESTION: #{qcontent} / GROUPE : #{qgroupe}"
        # debug "PID: #{pid} / RELPATH: #{pfile}\n"
      end
    end
    return @table_checkup
  end

end #/class
end #/String
