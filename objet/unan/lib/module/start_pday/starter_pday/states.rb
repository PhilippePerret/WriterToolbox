# encoding: UTF-8
class Unan
class Program
class StarterPDay

  attr_accessor :avertir_administration

  # ---------------------------------------------------------------------
  #   Méthodes d'état
  # ---------------------------------------------------------------------

  # Return true si le jour-programme du jour existe (donc avec de
  # nouveaux travaux)
  def has_new_works?
    abs_pday.exist?
  end

  # Retourne true si l'auteur veut recevoir un mail quotidien pour
  # son travail.
  def mail_journalier?
    @want_mail_journalier ||= auteur.daily_summary?
  end

  def avertir_administration?; !!self.avertir_administration end

end #/StarterPDay
end #/Program
end #/Unan
