# encoding: UTF-8
class Lien
  include Singleton

  # Méthode principale permettant de construire un lien
  # quelconque, pour éviter de répéter toujours le même code
  def build route, titre, options
    options ||= Hash::new
    options.merge!( href: route )
    titre.in_a(options)
  end

  # Lien pour s'inscrire sur le site
  def signup titre = "s'inscrire", options = nil
    build "user/signup", titre, options
  end
  alias :inscription :signup

  # Lien pour s'identifier
  def signin titre = "s'identifier", options = nil
    build "user/signin", titre, options
  end


  def subscribe titre = "s'abonner", options = nil
    build "user/paiement", titre, options )
  end
  alias :link_suscribe :lien_subscribe
  alias :lien_sabonner :lien_subscribe
  alias :lien_abonnement :lien_subscribe

end

def lien ; @lien ||= Lien.instance end
