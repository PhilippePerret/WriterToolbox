# encoding: UTF-8
class Ranking
  class << self

    def init
      # On crée le dossier pour les pages de résultats (que curl enregistre
      # dans un fichier — pour une consultation aisée)
      `rm -rf #{folder_google_pages}`
      `mkdir -p #{folder_google_pages}`
    end

    # Méthode appelée pour ré-initialiser tous les résultats, c'est-à-dire
    # détruire le fichier Marshal qui contient les données récoltées au
    # cours des recherches.
    def reset_data
      File.unlink marshal_file if File.exist? marshal_file
    end


    # Méthode qui retourne le prochain mot clé à étudier, en fonction
    # du contenu du fichier Marshal
    #
    # Cette méthode est utilisée par le fichier run_spec.rb qui se
    # charge de la recherche du ranking
    #
    def next_keyword
      @data_marshal = nil # pour forcer la lecture du fichier
      KEYWORDS.each do |kw|
        data_marshal.key?(kw) || ( return kw )
      end
      return nil # => on peut arrêter
    end


    # Pour la méthode Curl, le site google en a besoin
    def user_agent
      @user_agent ||= 'Googlebot/2.1 (http://www.googlebot.com/bot.html)'
    end

    def search_url
      @search_url ||= 'http://www.google.fr/search'
    end

    def cookie_path
      @cookie_path ||= File.expand_path('./tmp/curl_cookie.txt')
    end

    def folder_google_pages
      @folder_google_pages ||= './tmp/google_pages'
    end

    # Toutes les données enregistrées dans le fichier marshal
    def data_marshal
      @data_marshal ||= begin
        if File.exist? marshal_file
          File.open(marshal_file,'rb'){|f| Marshal.load(f)}
        else
          Hash.new
        end
      end
    end
  def marshal_file
      @marshal_file ||= begin
        dos = File.expand_path('./tmp/ranking')
        `mkdir -p '#{dos}'`
        File.join('.', 'tmp', 'ranking', 'data.msh')
      end
    end

  end #/<< self
end #/Ranking
