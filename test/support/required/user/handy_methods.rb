# encoding: UTF-8
=begin

Méthodes utiles pour les Users

=end
def login_phil
  require './data/secret/data_phil'
  online = SiteHtml::TestSuite::online?
  d = {
    url: "#{site.send(online ? :distant_url : :local_url)}/user/login",
    data: "login[mail]=#{DATA_PHIL[:mail]}&login[password]=#{DATA_PHIL[:password]}"
  }
  req = SiteHtml::TestSuite::Request::CURL::new(nil, d)
  req.execute
  req.ok? || raise( "Impossible de logger Phil…")
  return true
end
alias :identify_phil :login_phil
alias :identify_admin :login_phil
alias :login_admin :login_phil
