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
    end
  end
end
