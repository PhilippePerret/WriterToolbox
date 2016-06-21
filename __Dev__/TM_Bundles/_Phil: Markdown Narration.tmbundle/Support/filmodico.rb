# encoding: UTF-8
=begin
  Module pour TextMate permettant de récupérer la balise d'un film.
=end
require 'mysql2'

class Filmodico
  require_relative 'data_mysql'
  class << self
    
    attr_reader :extrait
    
    # Méthode qui retourne un code de type snippet pour mettre la balise
    # correspond à l'extrait de mot.
    # Si un seul mot correspond à la recherche, on peut retourner un snippet
    # simple, sinon on retourne un snippet permettant de choisir le mot.
    def get_as_snippet extrait_titre
      @extrait = extrait_titre
      films = submit_requete
      if films.count == 1
        "FILM[#{films.first}]"
      elsif films.count == 0
        "#{extrait_titre}?"
      else
        #Plusieurs films
        "FILM[${1|#{films.join(',')}|}]$0"
      end
    end
    
    def submit_requete
      return client.query(requete).collect { |props| props.first[1] }
    rescue Exception => e
      return [e.message]
    end
    def client
      @client ||= begin
        Mysql2::Client.new(DATA_MYSQL.merge(database: 'boite-a-outils_biblio'))
      end
    end
    
    def requete
      ext = extrait.gsub(/'/, "\\'")
      where_clause = "titre LIKE '%#{ext}%' OR titre_fr LIKE '%#{ext}%'"
      <<-SQL
SELECT film_id
  FROM filmodico
  WHERE #{where_clause};
      SQL
    end
  end #<< self
end