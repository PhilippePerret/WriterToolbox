# encoding: UTF-8


def image path, options = nil
  options ||= Hash::new
  path = (site.folder_images + path).to_s
  path.in_image(options)
end


def lien_suscribe titre = nil, options = nil
  site.lien_suscribe( titre, options )
end
alias :link_suscribe :lien_suscribe
alias :lien_sabonner :lien_suscribe
alias :lien_abonnement :lien_suscribe
