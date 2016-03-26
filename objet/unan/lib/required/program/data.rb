# encoding: UTF-8
=begin

Méthode de data du programme

=end
class Unan
class Program

  include MethodesObjetsBdD

  # ID du programme (dans la table Unan::table_programs)
  attr_reader :id

  # ---------------------------------------------------------------------
  #   Data du programme
  # ---------------------------------------------------------------------
  # {User} Auteur du programme
  def auteur_id     ; @auteur_id ||= get(:auteur_id)    end
  # {String} Options du programme
  def options       ; @options ||= get(:options) || ""  end
  def points        ; @points   ||= get(:points) || 0   end
  def created_at    ; @created_at ||= get(:created_at)  end
  def updated_at    ; @updated_at ||= get(:updated_at)  end
  # {Fixnum} Le rythme
  # ATTENTION : c'est une préférence, pas une donnée du programme
  def rythme        ; @rythme ||= user.preference(:rythme) || RYTHME_STANDARD end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------
  def auteur        ; @auteur ||= User::get(auteur_id)  end

  # Coefficient de durée du jour-programme du programme courant
  # @usage : On MULTIPLIE la durée réelle par ce nombre pour
  # obtenir la durée-programme.
  # DURÉE_RÉELLE * coefficient_duree = DURÉE_PROGRAMME
  # => DURÉE_RÉELLE = DURÉE_PROGRAMME * coefficiant_duree
  # ATTENTION : si cette méthode est déplacée, il faut modifier
  # le path dans la méthode `user#etat_des_lieux_programme_unan`
  # qui charge ce fichier (en standalone) pour calculer les
  # durée des travaux
  def coefficient_duree ; @coefficient_duree ||= 5.0 / rythme end

end # /Program
end # /Unan
