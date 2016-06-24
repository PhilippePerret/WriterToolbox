# encoding: UTF-8
=begin

Class Unan::Program::Work
-------------------------------
Un travail du programme Un An Un Script exécuté par un auteur.
Il renvoie directement à un travail absolu dont il est l'instance
pour l'auteur.

Note : Pour voir les données absolues du travail, cf. la classe
AbsWork.
=end
class Unan
class Program
class Work

  include MethodesMySQL

  # {Fixnum} ID du programme dans la table des travaux
  # propre au programme.
  attr_reader :id

  # {Unan::Program} Program auquel appartient le travail
  attr_reader :program

  # Instanciaiton du Work
  # +wid+ Identifiant du travail. Note : CE N'EST PLUS l'id
  # du travail absolu. Note : Il est nil à l'instanciation
  def initialize program, wid
    program = program.program if program.instance_of?(User)
    @program  = program
    @id       = wid
  end

  # Marque un travail terminé.
  #
  # La méthode est appelée par la route "work/<id>/complet?in=unan/program"
  # invoquée par les bouton "Marquer fini" dans le bureau de l'auteur
  # Elle produit :
  #   - met le travail au statut 9 (status)
  #   - met les points dans le travail en fonction du retard
  #     éventuel.
  #   - ajoute les points au programme de l'user
  # +must_add_point+ permet de définir s'il faut ajouter ou non les points
  # de ce travail. C'est utile par exemple pour les pages de cours,
  # qu'il suffirait de lire et de remettre à lire en boucle pour ajouter
  # chaque fois les points de la lecture.
  # C'est utile aussi pour les questionnaires ré-utilisable (multi?)
  def set_complete(must_add_point = true)
    dwork = {status: 9, updated_at: NOW, ended_at: NOW}
    dwork.merge!(points: points_for_travail) if must_add_point
    set(dwork)
    add_mess_points =
      if must_add_point && points_for_travail > 0
        user.add_points( points_for_travail )
        " (#{abs_work.points} nouveaux points)"
      else
        ""
      end
    flash "Travail ##{id} terminé#{add_mess_points}."
  end

  # Les points récoltés pour ce travail, en fonction des
  # points par défaut et de l'éventuel retard
  def points_for_travail
    @points_for_travail ||= begin
      points4travail =
        if abs_work.points.to_i == 0 # si nil
          0
        else
          # Il faut voir si le travail a du retard et si c'est le
          # cas retirer des points.
          # On retire 5% des points par jour de retard
          pts = abs_work.points
          if NOW > expected_end
            nombre_jours_retard = (NOW - expected_end) / 1.day
            pts = (pts - (nombre_jours_retard * (pts * 5.0 / 100))).to_i
            pts > 0 || pts = 0
          end
          pts
        end
    end
  end

  # {BdD::Table} Table contenant les travaux propres de l'user, c'est-à-dire
  # ses résultats divers sur les travaux absolus.
  # Noter que c'est la méthode `program.table_works` qui doit être
  # impérativement invoquée pour procéder à la construction de
  # la table si elle n'existe pas encore.
  def table
    @table ||= program.table_works
  end

end #/Work
end #/Program
end #/Unan
