# encoding: UTF-8
class Video

  extend MethodesMainObjets

  class << self

    def titre ; @titre ||= "Didacticiels vidéos".freeze end
    def data_onglets
      @data_onglets ||= begin
        d = {
          "Accueil" => 'video/home',
          "Aide"    => 'video/aide'
        }
        if user.admin?
          d.merge!("[Aide administration]" => 'video/aide_admin')
        end
        d
      end
    end

  end # / << self

end #/Video
