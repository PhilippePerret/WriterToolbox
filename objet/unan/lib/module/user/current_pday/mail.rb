# encoding: UTF-8
class User
class CurrentPDay

  # Envoi du rapport par mail
  def send_by_mail
    auteur.send_mail(
      subject:        "Rapport journalier du #{NOW.as_human_date(true, false, ' ')}",
      message:        assemblage_rapport,
      formated:       true,
      signature:      false # signature inutile
    )
  end

end #/CurrentPDay
end #/User
