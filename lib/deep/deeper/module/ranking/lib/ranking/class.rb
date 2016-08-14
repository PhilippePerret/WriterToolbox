# encoding: UTF-8
class Ranking

  # Le xième lien maximum
  NOMBRE_FOUNDS_MAX = 30 #200

  LAST_PAGE_INDEX = 3

  # Le nombre de pages maximum
  # Ne servira que si NOMBRE_FOUNDS_MAX n'est pas défini, pour définir le
  # nombre de liens maximum à afficher
  NOMBRE_PAGES_MAX      = 20
  NOMBRE_LIENS_PER_PAGE = 10


  class << self

    def init
      # On crée le dossier pour les pages de résultats (que curl enregistre
      # dans un fichier — pour une consultation aisée)
      `rm -rf #{folder_google_pages}`
      `mkdir -p #{folder_google_pages}`
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
  end #/<< self
end #/Ranking
