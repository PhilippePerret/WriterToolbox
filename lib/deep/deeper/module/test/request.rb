# encoding: UTF-8
class SiteHtml
class Test
class Request

  # Instance {SiteHtml::Test} du test (~fichier)
  #
  # @usage:   dans un fichier de test :
  #           request = exec_curl( "la requête CURL" )
  #
  attr_reader :test

  # {String} La requête à exécuter
  attr_reader :request

  def initialize test, requete
    @test     = test
    @request  = requete
  end

  # RETURN L'instance requête courante {SiteHtml::Test::Request}
  def execute
    @content = `#{request}`.force_encoding('utf-8')
    debug "RETOUR DE #{request}:\n#{@content}"
    debug "header : #{header.inspect}"
    return self
  end
  def ok?
    code_retour == 200 && texte_retour == "OK"
  end
  def content; @content end
  def header
    @header ||= begin
      content.match(/^HTTP\/(?:[0-9\.]+) ([0-9]{,3}) (.+?)Date/m).to_a
    end
  end
  def code_retour
    @code_retour ||= header[1].to_i
  end
  def texte_retour
    @texte_retour ||= header[2]
  end

end #/Request
end #/Test
end #/SiteHtml
