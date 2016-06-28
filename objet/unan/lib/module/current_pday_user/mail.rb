# encoding: UTF-8
class User
class CurrentPDay

  # Envoi du rapport par mail
  def send_rapport_quotidien
    auteur.send_mail(
      subject:            "B.O.A. UN AN UN SCRIPT - Rapport journalier du #{NOW.as_human_date(true, false, ' ')}",
      no_header_subject:  true,
      message:            rapport_complet,
      formated:           true,
      signature:          false # signature inutile
    )
  end

end #/CurrentPDay
end #/User
