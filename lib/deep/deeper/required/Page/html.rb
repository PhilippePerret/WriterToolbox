# encoding: UTF-8
class Page

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
    low_opacity_header = user.identified? ? "0.14" : "1"
    low_opacity_margin = user.identified? ? "0.352" : "1"
    <<-CSSS
<style type="text/css">
section#header{opacity:#{low_opacity_header}}
section#header:hover{opacity:1}
section#left_margin{opacity:#{low_opacity_margin}}
section#left_margin:hover{opacity:1}
div#chapiteau_logo{opacity:#{low_opacity_header}}
.adminonly{#{user.admin? ? '' : 'display:none;'}}
</style>
    CSSS
  end

end
