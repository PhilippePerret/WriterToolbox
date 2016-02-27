# encoding: UTF-8
=begin

=end
class Page

  def output
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
<title>#{page.title}</title>
<base href="#{site.base}" />
<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=latin-ext,latin' rel='stylesheet' type='text/css'>
<!--[if lt IE 9]>
<script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
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
