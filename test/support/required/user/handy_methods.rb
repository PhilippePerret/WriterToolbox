# encoding: UTF-8
=begin

Méthodes utiles pour les Users

=end

# Méthode pour logguer l'user
#   +pseudo+  Le pseudo type ("Phil", "Benoit", etc.)
#             Ou l'ID dans la table courante
#                 options doit alors définir :password
#             Ou NIL si toutes les données sont dans options
#   +options+ :mail et :password pour définir l'user
# 
def login_user(pseudo, options=nil)
  mail, password =
    case pseudo
    when NilClass
      [ options[:mail], options[:password] ]
    when Fixnum # délivré par ID
      d = User.table_users.get(pseudo)
      [ d[:mail], options[:password] ]
    when String
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
