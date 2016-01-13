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
      Vue::new(path, Unan::folder, Unan).output
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
        (itime+1).to_s.in_span.in_li
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
