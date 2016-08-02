# encoding: UTF-8
=begin

=end
class TestedPage
  class << self

    # = main =
    #
    # Établissement du rapport d'analyse des liens
    #
    def report

      case REPORT_FORMAT
      when :html
        report_html
      else

        say "\n\n\n"
        say "="*80
        say "= ANALYSE DES LIENS DU #{Time.now}"
        say "="*80
        say "\n\n"
        say "= NOMBRE DE ROUTES TESTÉES : #{instances.count}"
        say "= NOMBRE PAGES INVALIDES   : #{invalides.count}"
        say "= NOMBRE PAGES VALIDES     : #{instances.count - invalides.count}"
        say "\n"

        say "\n==============================="
        say   "= 20 ROUTES LES PLUS VISITÉES ="
        say   "==============================="
        routes_les_plus_visitees.each do |tpage|
          say "= #{tpage.route} - #{tpage.call_count} fois"
        end
        say "\n================================="
        say   "= 10 ROUTES LES MOINS VISITÉES  ="
        say   "================================="
        routes_les_moins_visitees.each do |tpage|
          say "= #{tpage.route} - #{tpage.call_count} fois"
        end
        say "\n"

        # ---------------------------------------------------------------------
        #   Pages invalides
        if invalides.count > 0
          say "\n========================="
          say   "= PAGES INVALIDES (#{invalides.count}) ="
          say   "========================="
          invalides.each do |route|
            tpage = instances[route]
            errs = tpage.errors.join("\n")
            say "# Route : #{route}"
            say "# Invalidité : #{errs}"
          end
        else
          say "= AUCUNE PAGE INVALIDE ! ="
        end
      end
      # / Fin du case format
    end

    # Retourne la durée de l'opération, en secondes
    #
    def duree_operation
      seconds = end_time.to_i - start_time.to_i
      minutes = seconds / 60
      seconds = seconds % 60
      s_mns = minutes > 1 ? 's' : ''
      s_scs = seconds > 1 ? 's' : ''
      hduree = "#{seconds} seconde#{s_scs}"
      minutes == 0 || hduree = "#{minutes} minute#{s_mns} #{hduree}"
      return hduree
    end

    def pages_sorted_by_calls
      @pages_sorted_by_calls ||= begin
        instances.values.sort_by{ |v| v.call_count }
      end
    end

    def routes_les_plus_visitees nombre = 20
      pages_sorted_by_calls[-nombre..-1].reverse
    end
    def routes_les_moins_visitees nombre = 10
      pages_sorted_by_calls[0..nombre]
    end

    # Produit et ouvre le rapport HTML
    def report_html
      Report.html_version
    end

  end #/ << self TestedPage

  class Report
  class << self

    # = main =
    # Construit la version HTML du rapport et l'ouvre
    #
    def html_version
      File.open(path,'wb'){|f| f.write code_html}
      `open -a '#{BROWSER_APP}' #{path}`
    end

    # Titre humain du rapport
    def titre
      "Links Analysis du #{Time.now}"
    end

    # = main =
    #
    # Retourne le code pour les infos générales sur
    # l'analyse.
    def general_infos
      # Nombre de routes totales testées
      c = ""

      c << in_div(
        in_span(TestedPage.instances.count, class: 'fvalue') +
        in_span('Nombre de routes testées', class: 'libelle'),
        class: 'ligne_value'
      )

      # Nombre total de liens
      c << in_div(
        in_span(TestedPage.links_count, class: 'fvalue') +
        in_span('Nombre total de liens', class: 'libelle'),
        class: 'ligne_value'
      )

      # Nombre d'invalidités (rouge)
      css = ['fvalue']
      css << 'warning' if TestedPage.invalides.count > 0
      c << in_div(
        in_span(TestedPage.invalides.count, class: css.join(' ')) +
        in_span('Nombre de routes invalides', class: 'libelle'),
        class: 'ligne_value'
      )

      c << in_div(
        in_span(TestedPage.duree_operation, class: 'fvalue') +
        in_span('Durée de l’opération', class: 'libelle'),
        class: 'ligne_value'
      )

      return c.force_encoding('utf-8')
    end

    # = main =
    #
    # Méthode principale retournant le code pour le fieldset des
    # fréquences, avec les routes les plus visitées, les moins visitées,
    # etc.
    def rapport_frequence
      c = String.new

      cmost =
        in_div('Routes les plus visitées', class: 'stitre') +
        TestedPage.routes_les_plus_visitees.collect do |tpage|
          in_div(
            in_span("#{tpage.call_count} fois", class: 'fright') +
            in_span("#{tpage.route}")
            )
        end.join('')

      cless = in_div('Routes les moins visitées', class: 'stitre') +
        TestedPage.routes_les_moins_visitees.collect do |tpage|
          in_div(
            in_span("#{tpage.call_count} fois", class: 'fright') +
            in_span("#{tpage.route}")
            )
        end.join('')

      in_tag('section', cless, class: 'colLow') +
      in_tag('section', cmost, class: 'colHigh')
    end


    # = main =
    #
    # Méthode principale renvoyant le code pour indiquer les
    # invalidités des pages
    def rapport_invalidites
      # # Pour le test :
      # TestedPage.instance_variable_set('@invalides', TestedPage.instances.keys[0..4])

      TestedPage.invalides.collect do |route|
        tpage = TestedPage[route]

        # Par erreur, il peut arriver que la page
        # n'existe pas. Peut-être lorsque la merge
        # s'est mal passée
        if tpage.nil?
          debug "# PROBLÈME AVEC LA ROUTE : #{route} (la TestedPage n'existe pas/plus)"
          next
        end

        div_id = "div_route_#{route.gsub(/\//,'_')}"

        c = ''

        c << in_span("<a href=\"javascript:void(0)\" onclick=\"DOMRemove('#{div_id}', 'linvalidites')\">x</a>", class: 'btn_close')

        # Pour indiquer la route et pouvoir l'atteindre
        c << in_div(
          in_span("<a href='#{tpage.url}' target='_blank'>#{tpage.url}</a>", class: 'link_url') +
          in_span(tpage.route, class: 'route'),
          class: 'main'
            )
        errors_list =
          tpage.errors.collect do |err|
            in_div(err, class: 'error')
          end.join('')
        div_errors_list = in_div(errors_list, class: 'errors_list')
        div_nombre_errors =
          in_div(
            in_span('Nombre d’erreurs', class: 'libelle') +
            in_span(tpage.errors.count, class: 'value')
          )
        # Un lien pour ouvrir un des referrer de la route, c'est-à-dire
        # une page qui l'ouvre.
        referrer = TestedPage[tpage.call_froms.last]
        link_to_referrer = "<a href='#{referrer.url}' target='_blank'>#{referrer.url}</a>"
        div_link_to_referrer =
          in_div(
            in_span('Appelée par exemple par…', class: 'libelle') +
            in_span(link_to_referrer, class: 'value')
          )

        pre_raw_code =
          in_div('Code brut de la page (ci-dessus, glisser la souris pour le faire apparaitre)') +
          in_tag('pre', tpage.raw_code_report, class: 'raw_code')

        c << in_div(
                div_link_to_referrer +
                div_nombre_errors +
                div_errors_list +
                pre_raw_code,
                class: 'ligne_value'
                )

        # Le code HTML total, dans un div
        # Pour le collect
        in_div(c, class: 'bad_route', id: div_id)

      end.join('')
    end


    def code_html
      # require 'erb'
      ERB.new(code_gabarit_html).result(bind)
    end
    def code_gabarit_html
      File.open(path_gabarit,'rb'){|f|f.read.force_encoding('utf-8')}
    end

    # ---------------------------------------------------------------------
    #   Méthodes fonctionnelles
    # ---------------------------------------------------------------------

    def bind; binding() end

    def in_tag tag, content, options = nil
      options ||= Hash.new
      attrs = []
      attrs << "id='#{options[:id]}'" if options.key?(:id)
      attrs << "class='#{options[:class]}'" if options.key?(:class)
      attrs << "style='#{options[:style]}'" if options.key?(:style)
      attrs = attrs.empty? ? '' : ' ' + attrs.join(' ')
      "<#{tag}#{attrs}>#{content}</#{tag}>"
    end
    def in_div content, options = nil; in_tag('div', content, options) end
    def in_span content, options = nil; in_tag('span', content, options) end

    # Path du rapport
    def path
      @path ||= File.join(folder, 'report.html')
    end
    def path_gabarit
      @path_gabarit ||= File.join(folder, 'gabarit.erb')
    end

    def folder
      @folder ||= File.join(MAIN_FOLDER,'report')
    end

  end #/ << self TestedPage::Report
  end #/Report
end #/TestedPage
