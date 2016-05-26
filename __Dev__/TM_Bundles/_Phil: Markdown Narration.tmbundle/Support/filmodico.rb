# encoding: UTF-8
=begin
  Module pour TextMate permettant de récupérer la balise mot d'un mot
=end
require 'sqlite3'

class Filmodico
  BASE_SCENODICO = '/Users/philippeperret/Sites/WriterToolbox/database/data/filmodico.db'
  class << self
    
    attr_reader :extrait
    
    # Méthode qui retourne un code de type snippet pour mettre la balise
    # correspond à l'extrait de mot.
    # Si un seul mot correspond à la recherche, on peut retourner un snippet
    # simple, sinon on retourne un snippet permettant de choisir le mot.
    def get_as_snippet extrait_titre
      @extrait = extrait_titre
      films = get
      if films.count == 1
        "FILM[#{films.first}]"
      elsif films.count == 0
        "#{extrait_titre}?"
      else
        #Plusieurs films
        "FILM[${1|#{films.join(',')}|}]$0"
      end
    end
    def get
      submit_requete
    end
    
    def submit_requete
      pdb = database.prepare requete
      return pdb.execute.collect { |props| props.first.to_s }
    rescue Exception => e
      return [e.message]
    end
    def database
      @database ||= SQLite3::Database.new(BASE_SCENODICO)
    end
    
    def requete
      ext = extrait.gsub(/'/, "\\'")
      where_clause = "titre LIKE '%#{ext}%' OR titre_fr LIKE '%#{ext}%'"
      <<-SQL
SELECT film_id
  FROM films
  WHERE #{where_clause} 
  COLLATE NOCASE;
      SQL
    end
  end #<< self
end