# encoding: UTF-8
=begin

Méthode de data du programme

=end
class Unan
class Program

  include MethodesMySQL

  # ID du programme (dans la table Unan::table_programs)
  attr_reader :id

  # ---------------------------------------------------------------------
  #   Data du programme
  # ---------------------------------------------------------------------
  # {User} Auteur du programme
  def auteur_id     ; @auteur_id  ||= get(:auteur_id)       end
  def projet_id     ; @projet_id  ||= get(:projet_id)       end
  # {String} Options du programme
  def options       ; @options    ||= get(:options) || ""   end
  def created_at    ; @created_at ||= get(:created_at)      end
  def updated_at    ; @updated_at ||= get(:updated_at)      end
  def rythme        ; @rythme     ||= get(:rythme)          end

  # Valeurs rechargées chaque fois
  def points
    get(:points) || 0
  end

  # {Fixnum} Jour-programme courant
  # On peut le définir par <auteur>.program.current_pday = <i jour programme>
  def current_pday
    @current_pday ||= get(:current_pday)
  end
  # Définit le nouveau jour-programme (en définissant également
  # sa date de démarrage)
  def current_pday= valeur
    set(current_pday: valeur.to_i, current_pday_start: NOW)
    # @current_pday       = valeur
    # @current_pday_start = NOW
  end
  # {Fixnum} Timestamp du démarrage du jour-programme courant
  def current_pday_start; @current_pday_start ||= get(:current_pday_start)  end

  # Variable qui consigne les retards
  # Cf. le manuel
  def retards ; @retards ||= get(:retards) end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------
  def auteur        ; @auteur ||= User.get(auteur_id)  end

  # Coefficient de durée du jour-programme du programme courant
  # @usage : On MULTIPLIE la durée réelle par ce nombre pour
  # obtenir la durée-programme.
  #     DURÉE_PROGRAMME = DURÉE_RÉELLE * coefficient_duree
  # =>  DURÉE_RÉELLE    = DURÉE_PROGRAMME.to_f / coefficient_duree
  def coefficient_duree ; @coefficient_duree ||= 5.0 / rythme end

end # /Program
end # /Unan
