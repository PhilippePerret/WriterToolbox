# encoding: UTF-8
=begin

Class Unan::Helper

Méthodes d'helper spécifiques


=end
class Unan
  class << self
    # Permet de charger une vue
    # @usage  Unan::view('path/relatif/depuis/dossier/objet_sans_erb')
    def view path
      Vue::new(path, Unan.folder, Unan).output
    end

    # Return un lien HTML pour rejoindre le bureau
    def lien_bureau titre = "bureau", options = nil
      options ||= Hash::new
      options.merge!( href: "bureau/home?in=unan" )
      ( titre.in_a options )
    end

    # Retourne un lien HTML pour rejoindre la collection
    # Narration
    def lien_collection_narration titre = "Collection Narration", options = nil
      options ||= Hash::new
      options.merge!(href: "cnarration/home")
      ( titre.in_a options )
    end

    def lien_forum titre = "Forum", options = nil
      options ||= Hash::new
      options.merge!(href: "forum/home")
      ( titre.in_a options )
    end

  end # << self

  class Helper

    class << self

      # Construit le code d'une graduation pour les
      # jour dans un div. Cf. le manuel Vues > Graduations-jours.md
      def graduation_jours data
        from_day  = data.delete( :from )  || 1
        to_day    = data.delete( :to )    || 365
        count_days = to_day - from_day

        # Les données pour les styles dynamiques de la
        # règle dont aura besoin `graduation_jours_styles`
        data[:day_width]        -= 1
        data[:padding_left]     ||= 12
        data[:background_color] ||= "#FFC740"
        data[:color]            ||= "#808080"
        data[:width]            = (data[:day_width] * (count_days+1)) + data[:padding_left]

        graduation_jours_styles(data) +
        (count_days + 1).times.collect do |itime|
          ijour = (itime + 1).to_s
          # (itime+1).to_s.in_span.in_li
          href = "abs_pday/#{ijour}/edit?in=unan_admin"
          # (itime+1).to_s.in_a(href:href).in_li
          ijour.to_s.in_span.in_li(onclick:"window.open('#{href}');")
        end.join.in_ul(class:'dayruler')
      end
      # Les styles dynamiques pour la règle
      def graduation_jours_styles data
        "<style type='text/css'>"+
          "ul.dayruler{background-color:#{data[:background_color]};padding-left:#{data[:padding_left]}px;width:#{data[:width]}}" +
          "ul.dayruler>li{color:#{data[:color]};width:#{data[:day_width]}px}"+
        "</style>"
      end
    end # << self
  end #/Helper
end #/Unan
