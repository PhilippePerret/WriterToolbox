# encoding: UTF-8
=begin

=end
class Page

  def output
    unless site.ajax?
      # Le code final
      cgi.out{
        cgi.html {
          cgi.head{ head } +
          cgi.body{ body }
        }
      }
    else
      # Retour d'une requête ajax
      Ajax::output
    end
  end

  def head
    @head ||= begin
      with_fonts = true # Mettre ONLINE quand on ne peut pas avoir de connexion
      fonts_google = if with_fonts
        <<-FONTS
        <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=latin-ext,latin' rel='stylesheet' type='text/css'>
        <!--[if lt IE 9]>
        <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
        FONTS
      else
        ""
      end
      <<-HEAD
<meta content="text/html; charset=utf-8" http-equiv="Content-type">
<title>#{page.title}</title>
<link rel="shortcut icon" href="view/img/favicon.ico" type="image/x-icon">
<link rel="icon" href="view/img/favicon.ico" type="image/x-icon">
<base href="#{site.base}" />
#{fonts_google}
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
      # c = String::new
      # debug "avant page.header : user.identified? #{user.identified?.inspect}"
      # c << page.header
      # debug "avant page.left_margin : user.identified? #{user.identified?.inspect}"
      # c << page.left_margin
      # debug "avant page.content : user.identified? #{user.identified?.inspect}"
      # c << page.content
      # debug "avant page.footer : user.identified? #{user.identified?.inspect}"
      # c << page.footer
      # debug "avant page.div_flash : user.identified? #{user.identified?.inspect}"
      # c << app.div_flash
      # debug "avant page.section_debug : user.identified? #{user.identified?.inspect}"
      # c << page.section_debug
      # c
    end
  end
end
