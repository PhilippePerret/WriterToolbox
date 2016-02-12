# encoding: UTF-8
=begin

Class FilmAnalyse::Manuel
Méthodes d'helper

=end
class FilmAnalyse
class Manuel
  class << self

    # Retourne un lien vers le fichier d'aide +relpath+ (depuis le
    # dossier manuel/+man_folder+) avec le titre +titre+ obligatoire
    def link_to man_folder, relpath, titre
      titre.in_a(href:"manuel/#{man_folder}?in=analyse&manp=#{relpath}")
    end

  end
end #/Manuel
end #/FilmAnalyse

def manuel_link_to man_folder, relpath, titre
  FilmAnalyse::Manuel::link_to man_folder, relpath, titre
end
alias :link_to_manuel :manuel_link_to
