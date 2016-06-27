# encoding: UTF-8
=begin

OBSOLÈTE : MAINTENANT, LA PAGE EST CONSTRUITE À CHAQUE ENREGSISTREMENT

Module de construction de la page semi-dynamique.

Elle transforme notamment toutes les balises et laisse
uniquement les textes dynamiques de type %{variable} qui
seront traités à la volée au chargement de la page.

=end
UnanAdmin.require_module 'page_cours'

class Unan
class Program
class PageCours

  include MethodesBuildPageSemiDynamique


end #/PageCours
end #/Program
end #/Unan

# Avant de reconstruire la page, il faut la sauver
# Non : L'enregistrer avant, manuellement, car il y a un problème qui
# se pose pour le moment.
# Note : Je n'ai pas confiance en require_relative pour la version
# ruby 1.9 qui se trouve sur le site (et ma méthode est plus courte).
# require _"edit_content.rb"
# page_cours.update
# Ensuite, on peut construire la page semi-dynamique
page_cours.build_page_semi_dynamique
redirect_to :last_route
