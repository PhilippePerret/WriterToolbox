# encoding: UTF-8
=begin

 - LATEX -

Contient les méthodes de correction pour la sortie LaTex des
fichier de la collection Narration (et plus généralement pour
tout fichier markdown/kramdown).

=end

# La méthode `kramdown` ajoutée à SuperFile
site.require_module 'kramdown'
# Librairie qui contient les méthodes pour corriger par
# exemple les PRINT_CHECKUP
require './objet/cnarration/lib/module/page/string_extension.rb'

class Cnarration
class Translator

  # Corrections à faire sur le texte avant de le transformer
  # par Kramdown
  def pre_corrections
    suivi << "    -> pré-corrections"

    @content = content

    # Il faut évaluer tous les code ERB contenu dans les documents.
    # Il faut le faire en deux temps. Dans un premier temps, au cours
    # de ces pré-corrections, il faut "protéger" les balises ERB pour
    # qu'elles ne soient pas interprétées par kramdown (on ne peut
    # pas évaluer le code tout de suite car il produira des balises
    # liens qui seraient supprimées).
    # Dans un deuxième temps, en post-correction, on évalue vraiment
    # les balises ERB pour les mettre dans le code final.
    @content.gsub!(/<%=?(.+?)%>/, "ERB-- \\1 --ERB")

    # 'tt' est une commande réservée dans LaTex, il faut donc transformer
    # les tt en tterm
    @content.gsub!(/\btt:/, 'tterm:')
    @content.gsub!(/tterm :/, 'tterm:') # il y en a, I don't know why

    # Tous les textes entre :|...| doivent être transformés pour
    # ne pas être interprétés par Kramdown comme des tableaux (longtable)
    @content.gsub!(/:\|(.+?)\|/, '[--\1--]')

    if @content.match(/[^_]CHECKUP/)
      $narration_page_id = self.page_id
      @content = String::formate_balises_question_checkup_in( @content, {output_format: :latex} )
      $narration_page_id = nil
    end

    # Mis en forme des documents si le texte contient DOC
    #
    # Noter que dans ce premier temps ça n'est pas du pur code
    # latex qui est construit, car les antislahs et les crochets
    # seraient traités par Kramdown. Voir la méthode
    # `String#traite_antislash_et_crochets_latex` dans le fichier
    # './lib/deep/deeper/module/kramdown/doc_in_text.rb' qui
    # explique comment on procède.
    #
    if @content.match(/DOC\//)
      @content = @content.mef_document(:latex)
      if page_id == 15
        debug "@content après mef_document : #{@content}"
      end
    end
  end

  # Corrections finales sur le texte Kramdowné
  def post_corrections
    suivi << "    -> post-corrections"

    # debug "content dans post_corrections : #{content}\n\n\n"

    # On finalise les balises LaTex des environnements
    # document et peut-être d'autres choses aussi.
    @content = content.traite_antislash_et_crochets_latex

    # On traie les balise ERB après les avoir protégées dans
    # les pré-corrections (cf. les pré-corrections où tout est
    # expliqué)
    evaluate_balises_erb

    # On traite les balises propres. Pour modifier le comportement
    # d'une méthode (comme par exemple celle qui gère les REF[...])
    # il suffit de la surclasser dans le module `string_extension`
    # de ce fichier
    @content = @content.formate_balises_propres

    # Correction des questions de checkup
    correction_questions_checkup

    # Deuxième temps de la correction des questions des checkups
    correction_listing_checkup

    # Latex mettant des tirets longs pour les listes itemize,
    # ce qui est normal avec la package french, on peut utiliser
    # le code suivant pour obliger des puces rondes de la taille
    # voulue
    # Pour la puce à utiliser, cf. le document d'aide `liste.pdf` dans
    # mon dossier d'aide à LaTex, qui donne toutes les valeurs
    # Note : Le package pifont est nécessaire.
    @content.gsub!(/^(begin\{itemize\})$/, '\1[label=\ding{32},font=\normal,itemsep=0pt]')

    # On ajoute un saut de ligne après le terme principal
    # d'un environnement description pour que la description commence
    # en dessous.
    @content.gsub!(/(\\item\[(.+?)\])/){"#{$1} \\hfill \\\\\n"}

    # Il faut traiter les [--...--] qui ont remplacé les :|...| pour
    # revenir à une commande latex normale
    @content.gsub!(/\b([a-zA-Z]+)\[\-\-(.+?)\-\-\]/){"\\#{$1}{#{$2}}"}

    # debug "content À LA FIN DE post_corrections : #{content}\n\n\n"

  end

  # Évaluation des balises ERB
  def evaluate_balises_erb
    @content.gsub!(/ERB--(.+?)--ERB/){
      code_erb = $1.strip
      begin
        # Il faut traiter le code ERB/ruby qui a pu être
        # transformé par kramdown
        code_erb.gsub!(/\\_/, '_')
        # Traitement de cas particuliers
        case code_erb
        when "user.pseudo" then "Ernest"
        else
          # debug "Évaludation de : #{code_erb.inspect}"
          res = eval( code_erb )
          res = res.purified # il faut supprimer toute balise HTML
        end
      rescue Exception => e
        debug e
        "[CODE ERB IMPOSSIBLE À ÉVALUER : #{code_erb}]"
      end
    }

  end

  # Correction des questions qui vont être rassemblées dans le
  # checkup final du livre (annexes)
  #
  # Note : ces deux méthodes s'exécutent dans la post-correction
  def correction_questions_checkup
    if content.match(/PRINT\\_CHECKUP/) || content.match(/EXPLICATION\\_CHECKUP/)
      # debug "PRINT_CHECKUP trouvé !"
      $narration_book_id = livre.id
      @content = String::formate_balises_print_checkup( @content, {format: :latex} )
      # debug "\n\n@content après traitement de print-chekcup : #{@content}\n\n"
      $narration_book_id = nil
    end
  end

  def correction_listing_checkup
    # Cf. le fichier ./objet/cnarration/lib/module/page/string_extension.rb où
    # est expliqué pourquoi il faut procéder en deux temps.
    if @content.match(/QUESTIONCHKP/)
      @content.gsub!(/LABEL\[(.+?)\]QUESTIONCHKP\[(.+?)\]/){
        label     = $1.freeze
        question  = $2.freeze
        "\\label{#{label}}\n\\questioncheckup{#{question}}"
      }
    end
  end

  # Finalisation du contenu du fichier
  #
  # Dans la version LaTex, il faut ajouter le titre du fichier avec
  # un label pour y faire référence
  def finalise_content
    @content = "\\subsection{#{page.titre}}\\label{#{page.latex_ref}}\n\n#{content}"

    # Kramdown, ce coquin, oublie de corriger les insécables,
    # je suis donc obligé de le faire moi-même jusqu'à nouvel
    # ordre
    @content.gsub!(/ /, '~{}')

  end

end #/Translator
end #/Cnarration
