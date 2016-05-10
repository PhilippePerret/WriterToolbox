# encoding: UTF-8
=begin

Module pour de l'aide

=end
class LaTexBook
class << self

  # Méthode principale qui retourne le texte de l'aide
  #
  # Il suffit dont de faire, par exemple dans la console :
  #     site.require_gem 'latexbook'
  #     h = LaTexBook::help
  #     sub_log( h )
  #
  def help
    <<-CODE
<pre>
REQUIS :

  - Un dossier contenant :
    - book_data.rb      Fichier définissant les données du livre
    - dossier "assets"  Pour mettre tous les fichiers assets propres
                        au livre à compiler.

FICHIER book_data.rb
  (utiliser la variable `livre` pour définir les données du livre
   ou la variable `book`)

  # Nom (affixe) du fichier PDF final
  livre.pdf_name        = "nom du fichier pdf SANS EXTENSION"

  # Dossier contenant les sources
  # C'est notamment ce dossier qui contiendra le fichier tdm
  livre.sources_folder  = "path/to/folder/sources/markdown"

  # --- Optionnelles ---

  # Si on veut que le book PDF final soit autre part qu'au même
  # niveau que le dossier des sources
  livre.pdf_file = "path/to/pdf_file.pdf"

  # Si on veut faire une version féminine du livre (il faut pour
  # cela que le code markdown contiennne des commandes LaTex de
  # la forme `\fem{}`)
  # Faux par défaut
  # livre.version_femme = true

  # Pour ouvrir le pdf à la fin de la compilation
  # livre.open_it = true


DOSSIER DES SOURCES
  (ce dossier ne se trouve pas forcément dans le dossier principal)
  - Contient tous les fichiers markdown à inclure dans le livre
  - Contient le fichier table des matières qui détermine l'ordre
    d'entrée des fichiers.
    tdm.yaml ou _tdm_.yaml ou TDM.yaml ou _TDM_.yaml

FICHIER tdm.yaml
  (s'il n'existe pas, les fichiers seront introduit dans l'ordre
   où ils se présentent, ce qui peut être très aléatoire)
  - Il doit se trouver à la racine du dossier des sources.
  - Il peut ne pas être défini
  - Il est construit en dossiers et fichiers qui correspondent à
  l'agencement des sources dans le dossier source. Les dossiers
  sont par exemple des parties ou des chapitres.

  Exemple code de la définition de la table des matières :

    dossier_un:
      - fichier_sans_extension
      - autre_fichier
    dossier_deux:
      - fichier
      - fichier_deux
    etc.

### Création du livre

    # Requérir le gem
    site.require_gem 'latexbook'

    # Seulement sur BOA ou un RestSite
    # Pour formater correctement les liens
    lien.output_format = :markdown

    ibook = LaTexBook::new("path/to/main/folder")
    if ibook.build
      flash ibook.message
    else
      error ibook.error
    end
</pre>
    CODE
  end

end #/<< self
end #/LaTexBook
