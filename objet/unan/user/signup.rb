# encoding: UTF-8
class Unan
  class << self

    # Méthode appelée lorsque l'user est déjà inscrit sur le
    # site pour voir le prix qu'il devra payer en réalité.
    # Si son abonnement date de plus de 9 mois, il lui faut
    # payer l'inscription complète, sinon, il a juste à payer
    # la différence.
    # {StringHTML} Retourne le code HTML du message indiquant
    # le tarif à payer par l'user
    def check_abonnement_user
      return "pour voir"
      if abonnement_recent?
        "Puisque vous venez récemment de vous inscrire (moins de 6 mois), votre abonnement au site est déduit de votre inscription au programme. Vous n'aurez donc que <strong>#{tarif_humain_user}</strong> à payer."
      else
        "Votre inscription au site remontant à plus de 6 mois, vous devez payer l'inscription complète au programme, soit #{tarif_humain_user}."
      end.in_p
    end

    def tarif_humain_user
      @tarif_humain_user ||= begin
        euros, centimes = "#{tarif_user.to_f}".split('.')
        centimes += "0" if centimes.length < 2
        "#{euros}.#{centimes}€"
      end
    end
    def tarif_user
      if abonnement_recent?
        Unan::tarif - site.tarif
      else
        Unan::tarif
      end
    end
    def abonnement_recent?
      true
    end
  end  # << self
end #/Unan
