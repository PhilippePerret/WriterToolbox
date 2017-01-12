# encoding: UTF-8
=begin

  Extension de la classe User pour la gestion du jour-programme
  courant de l'auteur.

  Class User::CurrentPDay
  -----------------------

=end
Unan.require_module 'current_pday_user'

class User
  include CurrentPDayClass
  def current_pday
    @current_pday ||= begin
      CurrentPDay.new(self)
    end
  end
  # Pour forcer le recalcul du jour-programme courant (et ses
  # listes) après un changement de statut.
  def reset_current_pday
    @current_pday = nil
    current_pday.reset_all_list
  end
end
