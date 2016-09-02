# encoding: UTF-8
class Video

  extend MethodesMainObjet

  class << self

    def titre ; @titre ||= "Les Didacticiels-vidéo".freeze end
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
