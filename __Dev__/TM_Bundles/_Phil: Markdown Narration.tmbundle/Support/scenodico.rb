# encoding: UTF-8
=begin
  Module pour TextMate permettant de récupérer la balise mot d'un mot
=end
require 'mysql2'

class Scenodico
  require_relative 'data_mysql'
  class << self
    
    attr_reader :extrait
    
    # Méthode qui retourne un code de type snippet pour mettre la balise
    # correspond à l'extrait de mot.
    # Si un seul mot correspond à la recherche, on peut retourner un snippet
    # simple, sinon on retourne un snippet permettant de choisir le mot.
    def get_as_snippet extrait_mot
      @extrait = extrait_mot
      mots = submit_requete
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
    
    def submit_requete
      client.query(requete).collect do |hmot|
        id  = hmot['id']
        mot = hmot['mot']
        "#{id}|${2:#{mot.downcase}}"
       end
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
      where_clause = "mot LIKE '%#{ext}%'"
      <<-SQL
SELECT id, mot
  FROM scenodico
  WHERE #{where_clause};
      SQL
    end
  end #<< self
end