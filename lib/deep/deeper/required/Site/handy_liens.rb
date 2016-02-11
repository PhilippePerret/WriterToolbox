# encoding: UTF-8


def lien_subscribe titre = nil, options = nil
  site.lien_subscribe( titre, options )
end
alias :link_suscribe :lien_subscribe
alias :lien_sabonner :lien_subscribe
alias :lien_abonnement :lien_subscribe

def lien_analyses_de_films titre = "analyses de films", options = nil
  site.build_lien("analyse/home", titre, options)
end
alias :lien_analyses :lien_analyses_de_films
