# encoding: UTF-8
=begin

  Extension de la classe User pour la gestion du jour-programme
  courant de l'auteur.

  Class User::CurrentPDay
  -----------------------

=end
class User
  def current_pday
    @current_pday ||= begin
      Unan.require_module 'current_pday_user'
      CurrentPDay::new(self)
    end
  end
end
