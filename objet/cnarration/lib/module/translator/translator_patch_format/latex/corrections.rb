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

    # 'tt' est une commande réservée dans LaTex, il faut donc transformer
    # les tt en tterm
    @content.gsub!(/\btt:/, 'tterm:')

    # Tous les textes entre :|...| doivent être transformés pour
    # ne pas être interprétés par Kramdown comme des tableaux (longtable)
    @content.gsub!(/:\|(.+?)\|/, '[--\1--]')

  end

  # Corrections finales sur le texte Kramdowné
  def post_corrections
    suivi << "    -> post-corrections"

    debug "content dans post_corrections : #{content}\n\n\n"

    @content = content.formate_balises_propres

    # Correction des questions de checkup
    #
    if content.match(/PRINT\\_CHECKUP/) || content.match(/EXPLICATION\\_CHECKUP/)
      debug "PRINT_CHECKUP trouvé !"
      $narration_book_id = livre.id
      @content = String::formate_balises_print_checkup( @content, {format: :latex} )
      debug "\n\n@content après traitement de print-chekcup : #{@content}\n\n"
      $narration_book_id = nil
    end

    if @content.match(/[^_]CHECKUP/)
      $narration_page_id = self.page_id
      @content = String::formate_balises_question_checkup_in( @content )
      $narration_page_id = nil
    end


    # Latex mettant des tirets longs pour les listes itemize,
    # ce qui est normal avec la package french, on peut utiliser
    # le code suivant pour obliger des puces rondes de la taille
    # voulue
    # Pour la puce à utiliser, cf. le document d'aide `liste.pdf` dans
    # mon dossier d'aide à LaTex, qui donne toutes les valeurs
    # Note : Le package pifont est nécessaire.
    @content.gsub!(/^(begin\{itemize\})$/, '\1[label=\ding{32},font=\normal]')

    # On ajoute un saut de ligne après le terme principal
    # d'un environnement description pour que la description commence
    # en dessous.
    @content.gsub!(/(\\item\[(.+?)\])/){"#{$1} \\hfill \\\\\n"}

    # Il faut traiter les [--...--] qui ont remplacé les :|...| pour
    # revenir à une commande latex normale
    @content.gsub!(/\b([a-zA-Z]+)\[\-\-(.+?)\-\-\]/){"\\#{$1}{#{$2}}"}


    # Kramdown, ce coquin, oublie de corriger les insécables,
    # je suis donc obligé de le faire moi-même jusqu'à nouvel
    # ordre
    @content.gsub!(/ /, '~{}')

    debug "content À LA FIN DE post_corrections : #{content}\n\n\n"

  end

end #/Translator
end #/Cnarration
