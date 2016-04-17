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

    if content.match(/PRINT_CHECKUP/) || content.match(/EXPLICATION_CHECKUP/)
      $narration_book_id = livre.id
      @content = String::formate_balises_print_checkup( @content )
      $narration_book_id = nil
    end

  end

  # Corrections finales sur le texte Kramdowné
  def post_corrections

    @content = content.formate_balises_propres

    # Kramdown, ce coquin, oublie de corriger les insécables,
    # je suis donc obligé de le faire moi-même jusqu'à nouvel
    # ordre
    @content.gsub!(/ /, '~{}')

    if @content.match(/[^_]CHECKUP/)
      $narration_page_id = self.page_id
      @content = String::formate_balises_question_checkup_in( @content )
      $narration_page_id = nil
    end


  end

end #/Translator
end #/Cnarration
