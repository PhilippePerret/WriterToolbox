# encoding: UTF-8
=begin

=end
class Page

  def output
    # Pour composer le code avant de mémoriser la dernière
    # route
    head
    body
    # On mémorise la dernière route à la fin
    app.session['last_route'] = site.current_route.route unless site.current_route.nil?
    # Le code final
    cgi.out{
      cgi.html {
        cgi.head{ head } +
        cgi.body{ body }
      }
    }
  end

  def head
    @head ||= begin
      <<-HEAD
<meta content="text/html; charset=utf-8" http-equiv="Content-type">
<title>#{site.title}</title>
<base href="#{site.base}" />
#{page.javascript}
#{page.css}
#{page.raw_css}
      HEAD
    end
  end

  def body
    @body ||= begin
      page.header         +
      page.left_margin    +
      page.content        +
      page.footer         +
      app.div_flash       +
      page.section_debug
    end
  end
end
