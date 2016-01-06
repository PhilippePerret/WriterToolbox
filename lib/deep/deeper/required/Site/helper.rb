# encoding: UTF-8
=begin

Méthode d'helper pour le site

@usage

    <%= site.<methode d'helper> %>

=end
class SiteHtml

  def tarif_humain
    @tarif_humain ||= "9,90€"
  end

end
