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
      code = String::formate_balises_question_checkup_in code
      String::rechercher_fichier_checkup_with_question
    end

    # Si c'est un fichier qui doit écrire les
    # questions de checkup
    if code.match("PRINT_CHECKUP")
      code = String::formate_balises_print_checkup code, options
    end

    return code
  end


  # Traitement particulier des images dans les pages de la
  # collection Narration (mais peut fonctionner pour tout autre
  # fichier SuperFile)
  def formate_balises_images_in code
    code.formate_balises_images(folder.to_s)
  end


end #/SuperFile

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
