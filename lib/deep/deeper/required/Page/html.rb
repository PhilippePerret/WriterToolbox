# encoding: utf-8
class Page

  # RETURN Le code HTML à copier dans la page en bas qui donne au lecteur
  # un nom de fichier pour nommer son fichier de correction
  def helper_filename_lecteur
    route =
      if site.current_route.nil?
        'site/home'
      else
        site.current_route.route
      end
    filename = route.gsub(/[\/\?\&=]/,'_') + '_corrs'
    filename.in_input(class: 'tiny center discret', onfocus:'this.select()', style: 'width: 200px').in_div(class: 'right')
  end

  # RETURN le bloc d'abonnement qui s'affiche lorsque le visiteur n'est pas
  # abonné au site, pour l'encourager à s'y inscrire ou s'y abonner
  def helper_bloc_abonnement
    # Quand faut-il l'afficher ou ne pas l'afficher ?
    afficher = true
    afficher = false if user.admin? || user.subscribed? || user.unanunscript?
    afficher = afficher && 
    if site.current_route.nil?
      false
    else
      croute = site.current_route.route
      if ['user/signin', 'user/noprofil', 'site/home', 'user/signup'].include?(croute) || croute.match(/(deconnexion|paiement)/)
        false
      else
        true
      end
    end

    afficher || (return '')
    (
      (
        lien.subscribe('S’ABONNER !', {class: 'darkgreen btn'}) +
        '<br>' +
        lien.aide(3, {titre: 'En savoir plus…', class: nil, style:'margin-top:7px;display:block'})
      ).in_div(class: 'fright center', style: 'margin-left: 2em') +
      "La Boite à Outils a <strong>BESOIN DE VOUS</strong> pour exister et poursuivre sa mission de propagation du savoir. <strong>SOUTENEZ-LA</strong> en vous abonnant pour seulement <strong>#{site.tarif_humain} pour toute une année</strong> !".in_div
    ). in_div(id: 'bloc_encourage_subscribe')
  end


  # Définit le titre à affiche dans la fenêtre et dans
  # l'historique du navigateur
  # Pour le définir dans une section, il faut utiliser
  # page.title = "<le titre>"
  def title
    if site.current_route.nil? || site.current_route.route == ""
      site.title
    else
      titre = ""
      titre << site.title_prefix if site.title_prefix
      titre << "#{site.title_separator || " | "}#{@title}" if @title
      titre || site.title
    end
  end
  def title= valeur
    @title = valeur
  end

  def javascript
    alljs = Array::new
    alljs += Dir["./lib/deep/deeper/js/first_required/**/*.js"]
    alljs += Dir["./lib/deep/deeper/js/required/**/*.js"]
    # Propres à l'application
    alljs += Dir["./js/first_required/**/*.js"]
    alljs += Dir["./js/required/**/*.js"]
    alljs += added_javascript unless added_javascript.nil?
    # debug "page.added_javascript: #{added_javascript.inspect}"
    # Fabrication de toutes les balises qui chargent les scripts
    alljs.collect do |js_path|
      "<script charset='utf-8' type='text/javascript' src='#{js_path}'></script>"
    end.join("\n")
  end

  def raw_javascript
    <<-HTML
<script type="text/javascript">
ONLINE = #{ONLINE.inspect};
OFFLINE = !ONLINE;
</script>
    HTML
  end

  def css
    allcss = Array::new
    allcss += Dir["#{site.folder_view}/css/**/*.css"]
    allcss += Dir["#{site.folder_gabarit}/**/*.css"]
    allcss += page.added_css unless page.added_css.nil?
    # app.debug.add "allcss: #{allcss.inspect}"
    # Fabrication de tous les liens pour les feuilles de style
    allcss.collect do |css_path|
      "<link charset='utf-8' href='#{css_path}' rel='stylesheet' type='text/css' />"
    end.join("\n")

  end

  # Code CSS à écrire en dur dans la balise <style> de la page
  # html
  def raw_css
    low_opacities = if user.identified?
      low_opacity = 1.0 - (0.08 * (app.session['user_nombre_pages'] || 1))
      low_opacity = 0.14 if low_opacity < 0.14
      # On ne joue plus sur l'opacité du bandeau supérieur 'section#header'
      # 'div#chapiteau_logo' se trouve maintenant dans left_margin donc
      # on n'a pas besoin de le traiter non plus.
      ['section#left_margin', 'section#footer'].collect do |jid|
        "#{jid}{opacity:#{low_opacity}}"
      end.join("\n")
    else
      ""
    end
    low_opacity = user.identified? ? "0.14" : "1"
    low_opacity_header = user.identified? ? "0.5" : "1"
    low_opacity_margin = user.identified? ? "0.14" : "1"
    # low_opacity_margin = user.identified? ? "0.352" : "1"
    <<-CSSS
<style type="text/css">
#{low_opacities}
.adminonly{#{user.admin? ? '' : 'display:none;'}}
</style>
    CSSS
  end

end
