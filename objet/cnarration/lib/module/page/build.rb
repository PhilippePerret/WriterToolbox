# encoding: UTF-8
=begin
Constructeur d'une page .md vers la page semi-dynamique qui sera
affichée sur le site.

Pour la construire, on se sert du module de la collection version MD.
=end

# Requérir l'extension SuperFile qui va ajouter les méthodes
# de traitement des fichiers Markdown.
site.require_module 'kramdown'

class SuperFile

  # Méthodes permettant d'ajouter des formatages propres
  # Elle est appelée par la méthode de formatage kramdown
  # de SuperFile quand elle existe.
  #
  # Note : On ne met pas le traitement des images dans
  # cette méthode car elle pourrait peut-être servir plus
  # tard pour tout type de texte, pas seulement les textes
  # des pages de la collection Narration.
  #
  def formatages_additionnels code, options = nil

    # Si le fichier contient des balises CHECKUP, il
    # faut les traiter pour qu'elles puissent
    # apparaitre à la fin.
    # Et puis on cherche aussi le(s) fichier(s) checkup
    # qui contient/iennent les questions de ce fichier
    # pour forcer leur actualisation
    if code.match(/[^_]CHECKUP/)
      code = formate_balises_question_checkup_in code
      rechercher_fichier_checkup_with_question
    end

    # Si c'est un fichier qui doit écrire les
    # questions de checkup
    if code.match("PRINT_CHECKUP")
      code = formate_balises_print_checkup code
    end

    return code
  end


  # Méthode qui recherche où le fichier en traitement ici, qui
  # contient des questions de checkup (automatique), place
  # ses questions (le ou les fichiers checkup affichant) les
  # questions pour pouvoir forcer leur actualisation.
  #
  # La méthode détruit les fichier ERB semidyn des checkups et
  # retourne un lien dans le message pour afficher ces fichiers
  #
  def rechercher_fichier_checkup_with_question
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
    flash "Les fichiers checkup suivants sont à actualiser :<br>#{liens}"
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
  # TODO: Quand la marque est trouvée, il faudrait indiquer
  # qu'il faut actualiser peut-être le fichier checkup ?
  # Mais comment trouver le fichier checkup ? => En faisant
  # une recherche rapide sur PRINT_CHECKUP
  #
  REG_QUESTION_CHECKUP = /(^)?[^_]CHECKUP\[(.*?)(?:\|(.*?))?\]($)?/o
  def formate_balises_question_checkup_in code
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

      repere = <<-HTML
<!-- CHECKUP[#{$narration_page_id}|#{q_id}|#{question}|#{groupe}] -->
      HTML
      ancre = "<a name='#{q_id}'></a>"

      # Texte final
      (isoled ? "\n" : "") + "#{ancre}#{repere}<span id='#{q_id}' class='qcheckup#{isoled ? ' iso' : ''}'>#{question}</span>"
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
  REG_PRINT_CHECKUP  = /PRINT_CHECKUP(?:\[(.*?)\])?/
  def formate_balises_print_checkup code

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
          debug "grp_and_arr: #{grp_and_arr.inspect}"
          grp, arr_question = grp_and_arr
          allq << ul_questions_checkup(arr_question, grp)
        end
        allq
      else
        ul_questions_checkup(@table_checkup.delete(groupe), groupe)
      end
    }

    # Il peut arriver qu'il reste des questions ou des groupes
    # de question qui n'ont pas été inscrites. Donc on fait comme
    # si un groupe "Autres questions" existait et on les écrit
    # à la fin du code
    unless @table_checkup.empty?
      flash "Des groupes de questions checkup ne sont pas traités (#{@table_checkup.keys.pretty_join}), je les ai ajoutés à la fin dans une rubrique “Autres questions”. Si tu veux les placer à un endroit précis, utilise les balises `PRINT_CHECKUP[&lt;groupe&gt;]` et un titre au-dessus."
      code += "Autres questions".in_h2 + @table_checkup.collect do |grp, arr_question|
          ul_questions_checkup(arr_question, grp)
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
  def ul_questions_checkup questions, groupe = nil
    # Liste des fichiers déjà mis en commentaire (ils servent à
    # savoir si le fichier doit être actualisé après modification
    # de la question ou du fichier la contenant)
    @files_checkups_traited ||= Hash::new

    # Boucle sur chaque question
    questions.collect do |hquestion|

      # La marque pour savoir que le fichier de la question est
      # utilisé ici et que s'il a été modifié il faut modifier aussi
      # ce fichier
      mark_file = unless @files_checkups_traited.has_key?(hquestion[:file])
        @files_checkups_traited.merge!(hquestion[:file] => true)
        "<!-- #{hquestion[:file]} -->"
      else
        ""
      end

      # Le lien pour rejoindre la question dans son fichier
      lien_vers_question = "-&gt;&nbsp;voir".in_a(href:"page/#{hquestion[:pid]}/show?in=cnarration##{hquestion[:id]}", target:"_blank")
      lien_vers_question = " (#{lien_vers_question})"

      # Mise en forme de la question affichée dans le checkup
      (
        hquestion[:question] +
        mark_file +
        lien_vers_question
      ).in_li(id: hquestion[:id])

    end.join.in_ul(
      id:     "checkup_groupe_#{groupe || '__autre__'}",
      class:  'checkup_groupe'
      )
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

  # Traitement particulier des images dans les pages de la
  # collection Narration (mais peut fonctionner pour tout autre
  # fichier SuperFile)
  def formate_balises_images_in code
    code.gsub(/IMAGE\[(.*?)(?:\|(.*?))?\]/){
      imgpath = imgpath_init = $1.to_s
      titalt_or_style = $2.to_s
      imgpath = imgpath.sub(/^"(.*?)"$/, '\1')
      debug "imgpath: '#{imgpath}'"
      imgpath += ".png" if File.extname(imgpath) == ""
      imgpath = seek_image_path_of(imgpath)
      titalt_or_style  = titalt_or_style.gsub(/'/, "’") unless titalt_or_style.nil?
      if imgpath != nil
        imgpath = imgpath.to_s
        case titalt_or_style
        when 'inline'
          imgpath.in_img()
        when 'fright', 'fleft'
          imgpath.in_img(class: titalt_or_style)
        else
          img_tag = "<img src='#{imgpath}' alt='Image: #{titalt_or_style}' />"
          legend = if titalt_or_style.nil?
            ""
          else
            "<div class='img_legend'>#{titalt_or_style}</div>"
          end
          "<center><div>#{img_tag}</div>#{legend}</center>"
        end
      else
        "IMAGE MANQUANTE: #{imgpath_init}"
      end
    }
  end

  # Cf. aide
  def seek_image_path_of prelimg
    in_img_book = path_image_in_folder_img_book prelimg
    return in_img_book.to_s if in_img_book.exist?
    in_img_collection = path_image_in_folder_img_narration prelimg
    return in_img_collection if in_img_collection.exist?
    in_folder_book_in_img_col = path_image_in_folder_book_in_img_narration(prelimg)
    return in_folder_book_in_img_col if in_folder_book_in_img_col!=nil && in_folder_book_in_img_col.exist?
    in_img_site = path_image_in_folder_img_site prelimg
    return in_img_site if in_img_site.exist?
    nil
  end
  def path_image_in_folder_img_book prelimg
    folder_narration = "./data/unan/pages_cours/cnarration/"
    rel_folder = (folder - folder_narration).to_s
    rel_folder = rel_folder.split("/")
    livre = rel_folder.shift
    rel_folder = File.join(rel_folder)
    folder_images = File.join("./data/unan/pages_semidyn/cnarration/", livre, 'img')
    SuperFile::new([folder_images, rel_folder, prelimg])
  end
  def path_image_in_folder_img_narration prelimg
    SuperFile::new(["./data/unan/pages_semidyn/cnarration/img", prelimg])
  end
  def path_image_in_folder_book_in_img_narration prelimg
    return nil if $narration_book_id.nil?
    folder_livre = Cnarration::LIVRES[$narration_book_id][:folder]
    SuperFile::new(["./data/unan/pages_semidyn/cnarration/img", folder_livre, prelimg])
  end
  def path_image_in_folder_img_site prelimg
    site.folder_images + prelimg
  end

end #/String

class Cnarration
class Page

  # Construit la page semi-dynamique
  #
  # +options+
  #   :quiet      Si TRUE, pas de message flash pour indiquer l'actualisation
  def build options = nil
    options ||= Hash::new
    options[:quiet]    = !!ONLINE unless options.has_key?(:quiet) # toujours silencieux en online
    options[:format] ||= :erb # peut être aussi :latex
    path_semidyn.remove if path_semidyn.exist?
    create_page unless path.exist?

    # Pour les balises références, il faut ces deux variables
    # globale (impossible de les passer autrement, ou trop compliqué)
    # Cf. dans ./lib/app/required/extension/string.rb
    $narration_current_page = self
    $narration_page_id      = self.id
    $narration_book_id      = self.livre_id

    # *** CONSTRUCTION DE LA PAGE ***
    path.kramdown( in_file: path_semidyn.to_s, output_format: options[:format] )

    # ré-initialiser ces variables pour éviter tout
    # problème.
    $narration_current_page = nil
    $narration_page_id      = nil
    $narration_book_id      = nil
    flash "Page actualisée." unless options[:quiet]
  end

end #/Page
end #/Cnarration
