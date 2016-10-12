# encoding: UTF-8
module CurrentPDayClass
  class CurrentPDay

  # Envoi du rapport par mail
  #
  # Le message (rapport_complet) est construit dans le module :
  # ./objet/unan/lib/module/current_pday_user/report.rb
  def send_rapport_quotidien force_offline = false
    auteur.send_mail(
      subject:            "B.O.A. UN AN - Rapport journalier du #{NOW.as_human_date(true, false, ' ')}",
      no_header_subject:  true,
      message:            rapport_complet,
      formated:           true,
      force_offline:      force_offline,
      signature:          false # signature inutile
    )
  end

end #/CurrentPDay
end #/module CurrentPDayClass
