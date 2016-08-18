# encoding: UTF-8
=begin
  Méthodes utiles pour produire un rapport fichier des résultats
  obtenus au cours des recherches de positionnement Google.
=end
class Ranking
  class << self

    def build_html_file options = nil
      options ||= Hash.new
      path_html_report.remove if path_html_report.exist?
      path_html_report.write whole_html_code
      if options[:open]
        `open -a Firefox "#{path_html_report.expanded_path}"`
      end
    end

    def whole_html_code
      '<html>'+
      head +
      body +
      '</html>'
    end

    def head
      '<head>'+
      '<style type="text/css">'+style_css+'</style>'+
      "<title>Ranking check</title>" +
      '</head>'
    end
    def body
      '<body>'+
      div_positionnement +
      '</body>'
    end

    def div_positionnement
      (
        build_div_positionnement
      ).in_div(id: 'positionnement_report')
    end

    def build_div_positionnement
      @data_marshal = nil # pour forcer la lecture du fichier
      data_marshal.collect do |keyword, data_kw|
        sorted = data_kw[:resultats][:per_domain].sort_by{|d,dd| d[:nombre_liens]}.reverse
        keyword.in_div(class: 'keywork') +
        sorted.collect do |domain, data_domain|
          (
            domain.in_div(class: 'name') +
            data_domain[:index_liens].join(', ').in_div(class: 'index_liens') +
            data_domain[:founds_data].collect{|h| h[:titre]}.join(', ').in_div(class: 'titres_liens') +
            data_domain[:founds_data].collect{|h| h[:href].in_li}.join('').in_ul(class: 'href_liens')
          ).in_div(class: 'domain')
        end.join('').in_div(class: 'domains')

      end
    end

    def style_css
      @style_css || file_style_css.read
    end
    def file_style_css
      @file_style_css ||= SuperFile.new(_('../css/main.css'))
    end

    def path_html_report
      @path_html_report ||= SuperFile.new('./tmp/ranking/html_report.html')
    end

  end #/<< self
end #/Ranking
