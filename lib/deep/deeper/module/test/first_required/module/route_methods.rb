# encoding: UTF-8
=begin

Module contenant les méthodes pour les routes, utile par exemple aux
tests des pages (des routes) et des formulaires.

=end
module ModuleRouteMethods
  
  require 'nokogiri'
  require 'open-uri'


  def url
    @url ||= "#{SiteHtml::TestSuite::current::base_url}/#{raw_route}"
  end

  def request req
    SiteHtml::TestSuite::Request::new(nil, req).execute
  end
  def request_only_header
    @request_only_header  ||= "curl -I #{url}"
  end
  def request_whole_page
    @request_whote_page   ||= "curl #{url}"
  end

  def code_page
    @code_page ||= begin
      request(request_whole_page).content
    end
  end

  def nokogiri_page
    @nokogiri_page ||= Nokogiri::HTML( open url )
  end

end
