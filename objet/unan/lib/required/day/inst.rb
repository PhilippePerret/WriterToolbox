# encoding: UTF-8
=begin

Instances Unan::Program::Cal::Day
---------------------------------
Gestion des jours du calendrier du programme

=end
class Unan
class Program
class Cal
  class Day
    attr_reader :cal
    attr_reader :time

    # +cal+ Instance Unan::Program::Cal du calendrier contenant ce jour
    def initialize cal, time
      @cal    = cal
      @time  = time
      debug "time:#{time} / #{date} / #{pday.index}"
    end

    # ---------------------------------------------------------------------
    #   Méthodes de programme
    # ---------------------------------------------------------------------

    # Jour-Programme. Quand le rythme est de 5, donc que le programme se
    # fait en un an, le jour-programme correspond au jour de l'année (c'est
    # le même numéro — yday = pday.index). Lorsque le rythme est différent de
    # 5, un jour-programme est plus court qu'un vrai jour si le rythme est
    # supérieur à 5 et le jour-programme est plus long qu'un jour si le rythme
    # est inférieur à 5.
    # Note : "pday" pour "Program-Day", jour-programme
    # Note : Les index des jours-programmes sont 1-start.
    def pday
      @pday ||= begin
        index = ((( time - cal.start ).to_f / (3600 * 24)) * (cal.rythme / 5.to_f)).round + 1
        ::Unan::Program::PDay::new(index)
      end
    end
    # ---------------------------------------------------------------------
    #   Méthodes de dates
    # ---------------------------------------------------------------------
    def first_day_of_month?
      @is_first_day_of_month = ( day == 1 ) if @is_first_day_of_month.nil?
      @is_first_day_of_month
    end
    def day   ; @day    ||= date.day      end
    def wday  ; @wday   ||= date.wday     end
    def month ; @month  ||= date.month    end
    def year  ; @year   ||= date.year     end
    def date
      @date ||= begin
        d = Time.at(time)
        d = Time::utc(d.year, d.month, d.day, 0, 0, 0)
        @time = d.to_i
        d
      end
    end
    def next_day
      # Time.new()
      Day::new(cal, time + (3600 * 24))
    end

    # ---------------------------------------------------------------------
    #   Méthodes d'état
    # ---------------------------------------------------------------------
    def today?        ; @is_today         ||= date.today?         end
    def before_today? ; @is_before_today  ||= date.before_today?  end
    def after_today?  ; @is_after_today   ||= date.after_today?   end

    # ---------------------------------------------------------------------
    #   Méthodes d'helper
    # ---------------------------------------------------------------------
    def mois_humain
      @mois_humain ||= "#{Time::MOIS[month - 1].capitalize} #{year}"
    end


  end # /Day
end # /Cal
end # /Program
end # /Unan
