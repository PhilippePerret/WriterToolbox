# encoding: UTF-8
class SiteHtml

  def offline?
    !online?
  end
  def online?
    @is_online ||= begin
      hhost = ENV['HTTP_HOST'].nil_if_empty
      hhost != nil && hhost != 'localhost' && hhost != '127.0.0.1'
    end
  end

end
