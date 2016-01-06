# encoding: UTF-8
=begin

Calendrier de travail permettant de savoir où on se trouve

Note : Ce calendrier permet aussi à l'administrateur de voir l'agencement
des étapes de travail.

=end
Dir["./objet/unan/lib/required/**/*.rb"].each{|m| require m}
class Unan
  class Program
    class Cal

      # Le div qui contient les jours de la semaine en lundi, mardi, etc.
      # Ce div est ajouté en dessous de chaque mois dans l'affichage du
      # calendrier de l'auteur
      def div_jours_semaine
        @div_jours_semaine ||= begin
          Time::JOURS.collect do |wday|
            wday.in_div(class:'wday')
          end.join('').in_div(class:'jours_semaines')
        end
      end

    end
  end
end
