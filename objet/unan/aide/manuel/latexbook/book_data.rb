# encoding: UTF-8
=begin

Fichier principal contenant les données du livre à construire, à
commencer par le nom du fichier et le dossier contenant les
sources `markdown`.

=end

# Nom du manuel à produire
livre.pdf_name        = "UAUS_Manuel"

# Si on doit définir explicitement le fichier de destination (dans
# le cas où il ne se trouve pas à l 'endroit voulu à la fin)
# livre.pdf_file = ""

# Le dossier contenant toutes les sources markdown ainsi que
# le fichier des tables des matières.
livre.sources_folder  = (site.folder_objet+'unan/aide/manuel/sources_md').to_s

# Pour l'ouvrir après compilation
livre.open_it = true
