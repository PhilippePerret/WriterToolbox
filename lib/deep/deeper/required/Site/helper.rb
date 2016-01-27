# encoding: UTF-8
=begin

Méthode d'helper pour le site

@usage

    <%= site.<methode d'helper> %>

=end
class SiteHtml

  def tarif_humain
    @tarif_humain ||= tarif.as_tarif
  end

  # Lien pour s'inscrire sur le site
  def lien_signup titre = "s'inscrire", options = nil
    options ||= Hash::new
    options.merge!(href: "user/signup")
    titre.in_a(options)
  end
end
