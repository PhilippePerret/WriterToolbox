# encoding: UTF-8
=begin
Méthodes pour les vues de la classe Page (singleton)
=end
class Page

  attr_reader :added_css
  attr_reader :added_javascript

  # Il faut "précharger" l'entête et le contenu de la page pour
  # définir toutes les choses avant d'appeler les méthodes qui
  # vont charger les css, les js, les messages, etc.
  # Cette méthode prédéfinit donc `header` et `content`
  def preload
    header
    content
    left_margin
  end

  # {StringHTML} Retourne le code HTML pour l'entête du
  # site. C'est le code qui se trouve dans le fichier :
  # view/deep/gabarit/header.erb
  def header
    @header ||= begin
      vue = Vue::new('header', site.folder_custom_gabarit)
      vue.output
    end
  end

  def content
    @content ||= (site.folder_gabarit + 'page_content.erb').deserb( site.objet_binded.respond_to?(:bind) ? site.objet_binded : nil )
  end

  def left_margin
    @left_margin ||= begin
      Vue::new('left_margin', site.folder_custom_gabarit).output
    end
  end

  # Page d'accueil (quand aucune route n'est définie ou que la
  # route n'a pas de vue)
  def home
    (site.folder_view + 'home.erb').deserb( site )
  end

  # Si une route est définie, contenant au moins 'objet' et 'method'
  # la vue objet/<objet>/<methode>.erb, si elle existe, est chargée
  def content_route
    @content_route ||= begin
      if site.current_route && site.current_route.vue
        site.current_route.vue.output
      end
    end
  end

  def login_box_unless_identified
    return "" if user.identified? || (site.current_route && ['user/signup','unan/signup'].include?(site.current_route.route))
    login_box
  end
  # {StringHTML} Return la boite d'identification
  # de l'user. Elle n'est affichée que si l'utilisateur
  # n'est pas identifié
  def login_box
    self.vue('user/login_form', site.folder_deeper_view)
  end

  def view relpath, dossier = nil, bindee = nil
    Vue::new(relpath, dossier, bindee).output
  end
  alias :vue :view

  # {StringHTML} Retourne le code de la vue debug.erb
  # Ne pas confondre avec le débug qui se construit avec la
  # méthode handy `debug` et qui est construit dans App/debug.rb
  def section_debug
    (site.folder_gabarit + 'debug.erb').deserb( site )
  end

  def add_css arr_css
    arr_css = [arr_css] unless arr_css.nil? || arr_css.instance_of?(Array)
    return if arr_css.nil? || arr_css.empty?
    @added_css ||= Array::new
    @added_css += arr_css
    # app.debug.add "@added_css: #{@added_css.inspect}"
  end

  def add_javascript arr_js
    arr_js = [arr_js] unless arr_js.nil? || arr_js.instance_of?(Array)
    return if arr_js.nil? || arr_js.empty?
    @added_javascript ||= Array::new
    @added_javascript += arr_js
    # debug "@added_javascript: #{@added_javascript.inspect}"
  end

end
