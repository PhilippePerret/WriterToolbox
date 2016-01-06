# encoding: UTF-8
class SiteHtml
class Admin
class Console
  class << self
    def current
      @current ||= begin
        new().init # return self
      end
    end
  end
end #/Console
end #/Admin
end #/SiteHtml
