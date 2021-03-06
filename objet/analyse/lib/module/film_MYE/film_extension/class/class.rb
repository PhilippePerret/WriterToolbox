# encoding: UTF-8
class FilmAnalyse
  class << self

    # Retourne un Array d'instances {FilmAnalyse::Film} de tous les
    # films du dossier data/analyse/film_MYE
    def archive_films_list options = nil
      @archive_films_list ||= begin
        Dir["#{folder_films_MYE}/*"].collect do |path|
          film_id = File.basename(path)
          # L'instance du film. Noter qu'il faut impérativement passer
          # par la méthode `FilmAnalyse::Film::get` car ce n'est pas
          # l'id (Fixnum) du film qui est transmis mais le `film_id`
          FilmAnalyse::Film::get(film_id)
        end
      end

      options ||= Hash.new
      options[:as] ||= :data

      case options[:as]
      when :ul
        @archive_films_list.collect do |ifilm|
          ifilm.intitule.in_a(href:"analyse/#{ifilm.id}/show").in_li
        end.join.in_ul(class:'films tdm')
      when :data then @archive_films_list
      end
    end

    def folder_films_MYE
      @folder_films_MYE ||= site.folder_data + 'analyse/film_MYE'
    end
  end # / << self
end #/FilmAnalyse
