# encoding: UTF-8
=begin

Méthodes utiles pour les Users

=end

def login_user(pseudo, options=nil)
  mail, password =
    if pseudo.nil?
      [ options[:mail], options[:password] ]
    else
      p = "./data/secret/data_#{pseudo.downcase}.rb"
      File.exist?(p) || raise( "Impossible de trouver les données de l'user #{pseudo} pour le logguer. Il faut créer son fichier #{p}." )
      require p
      hdata = Object.const_get("DATA_#{pseudo.upcase}")
      hdata != nil || raise( "Il faut définir les données de #{pseudo} dans un hash de nom `DATA_#{pseudo.upcase}` pour pouvoir le logguer avec `login_user`.")
      [ hdata[:mail], hdata[:password] ]
    end
  d = {url: login_url, data: "login[mail]=#{mail}&login[password]=#{password}"}
  req = SiteHtml::TestSuite::Request::CURL::new(owner=nil, d)
  req.execute
  req.ok? || raise( "Impossible de logger #{pseudo}…")
  return true
end

def login_url
  @login_url ||= begin
    online = SiteHtml::TestSuite::online?
    "#{site.send(online ? :distant_url : :local_url)}/user/login"
  end
end

def login_phil
  login_user 'phil'
end
alias :identify_phil :login_phil
alias :identify_admin :login_phil
alias :login_admin :login_phil
