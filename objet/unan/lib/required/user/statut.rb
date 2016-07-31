# encoding: UTF-8
=begin
Extension des instances User pour le programme UN AN
méthodes de status
=end
class User

  # True si l'user veut un récapitulatif journaliser
  # même lorsque son p-day ne génère pas de nouveaux
  # travaux
  def daily_summary?
    @has_daily_summary = preference(:daily_summary, false) if @has_daily_summary === nil
    @has_daily_summary
  end

end
