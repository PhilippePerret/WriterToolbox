# encoding: UTF-8
raise_unless user.analyste? || user.admin?
=begin

  Module pour extraire des données d'un film.

=end

AnalyseBuild.require_module 'extraction'

class AnalyseBuild
class << self


  # Texte à afficher dans la page lorsqu'aucun film n'est choisi
  def output_when_no_chantier
    'Cette section permet d’extraire des données de films collectés par le dépôt'.in_div(class: 'small italic') +
    'Choisir le film dont il faut extraire quelque chose dans la liste ci-dessous.'.in_div(class: 'italic') +
    'Vos films'.in_h3 +
    liste_films_current_user(href: "analyse_build/%{id}/extract") +
    'Films analysés par d’autres analyses'.in_h3 +
    liste_films_other_users(href: "analyse_build/%{id}/extract")
  end
end #<< self
end #/AnalyseBuild
