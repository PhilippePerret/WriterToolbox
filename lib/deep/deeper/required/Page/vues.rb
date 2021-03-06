# encoding: UTF-8
=begin
Méthodes pour les vues de la classe Page (singleton)
=end
class Page

  attr_reader :added_css
  attr_reader :added_javascript

  attr_accessor :fatal_error

  # = main =
  #
  # Méthode appelée juste après l'exécution de la route
  #
  # Il faut "précharger" l'entête et le contenu de la page pour
  # définir toutes les choses avant d'appeler les méthodes qui
  # vont charger les css, les js, les messages, etc.
  # Cette méthode prédéfinit donc `header` et `content`
  def preload
    return if site.ajax?
    app.benchmark('-> Page#preload')
    header
    footer
    content
    left_margin
    head
    @content = page.error_standard(fatal_error) unless fatal_error.nil?
    app.benchmark('<- Page#preload')
  rescue Exception => e
    @content = page.error_standard(e)
  end

  # On construit le body avant de l'afficher pour avoir tous
  # les éléments requis
  def prebuild_body
    return if site.ajax?
    app.benchmark('-> Page#prebuild_body')
    body
    site.current_route.nil? || begin
      app.session['last_route'] = route_courante
      # debug "[Page#prebuild_body] app.session['last_route'] mis à #{app.session['last_route'].inspect}"
    end
    app.benchmark('<- Page#prebuild_body')
  end

  # {StringHTML} Retourne le code HTML pour l'entête du
  # site. C'est le code qui se trouve dans le fichier :
  # view/deep/gabarit/header.erb
  def header
    @header ||= begin
      app.benchmark('-> Page#header')
      vue = Vue.new('header', site.folder_custom_gabarit)
      res = vue.output
      app.benchmark('<- Page#header')
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME D'HEADER : #{e.message}]"
    else
      return res
    end
  end

  def footer
    @footer ||= begin
      app.benchmark('-> Page#footer')
      vue = Vue.new('footer', site.folder_custom_gabarit)
      res =
        if vue.exist?
          vue.output
        else
          ""
        end
      app.benchmark('<- Page#footer')
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME DE FOOTER : #{e.message}]"
    else
      return res
    end
  end

  def content
    @content ||= begin
      app.benchmark('-> Page#content')
      res = (site.folder_gabarit + 'page_content.erb').deserb( site.objet_binded.respond_to?(:bind) ? site.objet_binded : nil )
      app.benchmark('<- Page#content')
      res
    end
  rescue Exception => e
    self.fatal_error = e
    "[PROBLÈME DE CONTENT : #{e.message}]"
  end

  # Définir le contenu à l'aide de `page.content = ...`
  # Pour le moment, seulement utilisé pour les protections de sections
  # et de modules
  # Noter que c'est @content_route qui est défini (cf. plus bas) pour
  # garder le code d'affichage dans un section#content
  # (JE NE COMPRENDS PAS LE MESSAGE CI-DESSUS...)
  def content= value
    @content_route = value
  end

  def left_margin
    @left_margin || ''
    # @left_margin ||= begin
    #   app.benchmark('-> Page#left_margin')
    #   res = Vue.new('left_margin', site.folder_custom_gabarit).output
    #   app.benchmark('<- Page#left_margin')
    # rescue Exception => e
    #   self.fatal_error = e
    #   "[PROBLÈME DE LEFT-MARGIN : #{e.message}]"
    # else
    #   return res
    # end
  end

  # Page d'accueil (quand aucune route n'est définie ou que la
  # route n'a pas de vue)
  def home
    app.benchmark('-> Page#home')
    home_file = site.folder_objet+'site/home.erb'
    res =
      if home_file.exist?
        page.view('home.erb', site.folder_objet+'site', site)
      else
        ""
      end
    app.benchmark('<- Page#home')
    return res
  end

  # Si une route est définie, contenant au moins 'objet' et 'method'
  # la vue objet/<objet>/<methode>.erb, si elle existe, est chargée
  #
  # Si la route n'est pas définie ou qu'elle est mauvaise, la méthode
  # retourne NIL ce qui provoque le chargement de la page d'accueil.
  #
  def content_route
    @content_route ||= begin
      if site.current_route
        if site.current_route.vue
          site.current_route.vue.output
        else
          # C'est ici qu'on passe en cas de mauvaise route.
          (site.folder_deeper_view + 'page/error_unknown_route.erb').deserb()
        end
      else
        nil # => L'accueil
      end
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME DE CONTENT_ROUTE : #{e.message}]"
    end
  end

  def login_box_unless_identified
    return "" if user.identified? || (site.current_route && ['signin', 'signup', 'paiement'].include?(site.current_route.method))
    login_box
  end
  # {StringHTML} Return la boite d'identification
  # de l'user. Elle n'est affichée que si l'utilisateur
  # n'est pas identifié
  def login_box
    self.vue('user/login_form', site.folder_deeper_view)
  end

  # Pour charger une vue
  #
  # @syntaxe    page.view(<file name>, <dossier objet>, <bindee>)
  def view relpath, dossier = nil, bindee = nil
    Vue.new(relpath, dossier, bindee).output
  end
  alias :vue :view

  # {StringHTML} Retourne le code de la vue debug.erb
  # Ne pas confondre avec le débug qui se construit avec la
  # méthode handy `debug` et qui est construit dans App/debug.rb
  def section_debug
    (site.folder_gabarit + 'debug.erb').deserb( site )
  end

  def add_css arr_css
    if arr_css.instance_of?(String) && File.directory?(arr_css)
      arr_css = Dir["#{arr_css}/**/*.css"]
    end
    arr_css = [arr_css] unless arr_css.nil? || arr_css.instance_of?(Array)
    return if arr_css.nil? || arr_css.empty?
    @added_css ||= Array::new
    @added_css += arr_css
    # app.debug.add "@added_css: #{@added_css.inspect}"
  end

  def add_javascript arr_js
    if arr_js.instance_of?(String) && File.directory?(arr_js)
      arr_js = Dir["#{arr_js}/**/*.js"]
    end
    arr_js = [arr_js] unless arr_js.nil? || arr_js.instance_of?(Array)
    return if arr_js.nil? || arr_js.empty?
    @added_javascript ||= []
    @added_javascript += arr_js
    # debug "@added_javascript: #{@added_javascript.inspect}"
  end

end
