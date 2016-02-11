# encoding: UTF-8


def image path, options = nil
  options ||= Hash::new
  path = (site.folder_images + path).to_s
  path.in_image(options)
end


def lien_subscribe titre = nil, options = nil
  site.lien_subscribe( titre, options )
end
alias :link_suscribe :lien_subscribe
alias :lien_sabonner :lien_subscribe
alias :lien_abonnement :lien_subscribe
