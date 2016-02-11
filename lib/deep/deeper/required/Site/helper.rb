# encoding: UTF-8
=begin

Méthode d'helper pour le site

@usage

    <%= site.<methode d'helper> %>

=end
class SiteHtml

  def tarif_humain(with_tarif_mois = false)
    if with_tarif_mois
      tarif_humain(false) + " (#{tarif_humain_par_mois})"
    else
      @tarif_humain ||= tarif.as_tarif
    end
  end

  def tarif_humain_par_mois suffix = " par mois"
    @tarif_humain_with_mois ||= begin
      parmois = (tarif / 12).round(1).as_tarif
      "#{parmois}#{suffix}"
    end
  end

  # Lien pour s'inscrire sur le site
  def lien_signup titre = "s'inscrire", options = nil
    options ||= Hash::new
    options.merge!(href: "user/signup")
    titre.in_a(options)
  end

  # Lien pour s'identifier
  def lien_signin titre = "s'identifier", options = nil
    options ||= Hash::new
    options.merge!(href: "user/signin")
    titre.in_a(options)
  end

  # Lien pour s'abonner au site
  def lien_subscribe titre = "s'abonner", options = nil
    options ||= Hash::new
    options.merge!(href: "user/paiement")
    titre.in_a(options)
  end
end
