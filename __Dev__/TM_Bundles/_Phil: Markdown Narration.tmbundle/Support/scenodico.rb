# encoding: UTF-8
=begin
  Module pour TextMate permettant de récupérer la balise mot d'un mot
=end
require 'sqlite3'

class Scenodico
  BASE_SCENODICO = '/Users/philippeperret/Sites/WriterToolbox/database/data/scenodico.db'
  class << self
    
    attr_reader :extrait
    
    # Méthode qui retourne un code de type snippet pour mettre la balise
    # correspond à l'extrait de mot.
    # Si un seul mot correspond à la recherche, on peut retourner un snippet
    # simple, sinon on retourne un snippet permettant de choisir le mot.
    def get_as_snippet extrait_mot
      @extrait = extrait_mot
      mots = get
      if mots.count == 1
        "MOT[#{mots.first}]"
      elsif mots.count == 0
        extrait_mot
      else
        #Plusieurs mots
        mots = mots.collect{|paire| paire.gsub(/\|/, "\\|")}
        "MOT[${1|#{mots.join(',')}|}]$0"
      end
    end
    def get
      submit_requete
    end
    
    def submit_requete
      pdb = database.prepare requete
      rs = 
        pdb.execute.collect do |paire|
          id, mot = paire
          "#{id}|${2:#{mot.downcase}}"
        end
      return rs
    rescue Exception => e
      return [e.message]
    end
    def database
      @database ||= SQLite3::Database.new(BASE_SCENODICO)
    end
    
    def requete
      ext = extrait.gsub(/'/, "\\'")
      where_clause = "mot LIKE '%#{ext}%'"
      <<-SQL
SELECT id, mot
  FROM mots
  WHERE #{where_clause} 
  COLLATE NOCASE;
      SQL
    end
  end #<< self
end