# encoding: UTF-8
=begin
  Module de méthodes checkant la validité de la page
=end
class TestedPage

  # Méthode principale checkant la validité de la
  # page.
  # Il faut définir la méthode check_if_valide dans le module
  # app.rb pour chaque application
  def valide?
    if @is_valide === nil
      if false == format_url_valide?
        # Avant tout, il faut que l'URL soit valide, par exemple qu'elle
        # ne soit pas entourée de mauvais guillemets
        @is_valide = false
        error "URL INVALIDE DANS SA FORME (#{@errors_format_url.join(', ')})"
      elsif url_with_ancre?
        # Check d'une URL avec une ancre, la page courante doit
        # contenir l'ancre spécifiée
        @is_valide = self.page_has_anchor?(url_anchor)
        @is_valide || error("ANCRE INTROUVABLE : #{url_anchor}")
      elsif ancre?
        # Check d'une ancre seule. Le code de la page doit posséder
        # l'ancre spécié, soit sous forme d'un <a name> soit sous forme
        # d'élément d'identifiant correspondant à l'ancre.
        @is_valide = referer.page_has_anchor?(ancre_of_route)
        @is_valide || error("ANCRE INTROUVABLE : #{ancre_of_route.inspect}")
      elsif hors_site?
        # Pour une page hors site, il suffit que l'header retourne
        # un code correct, donc 200 ou 3xx pour que ce soit bon
        @is_valide = page_hors_site_valide?
        @is_valide || error("STATUS HTML RETOURNÉ : #{html_status}")
      else
        # Check de la validité de la page URL spécifié
        @is_valide = check_if_valide
      end
    end
    @is_valide
  end

  # Return TRUE si le code de la page courante contient le tag
  # +tagname+ avec les options +tagoptions+ (qui peuvent contenir
  # :with, :text, :count etc.)
  #
  # +tagname+ peut être "div" ou "div#sonid", c'est le tagname mis
  # dans have_tag en RSpec
  #
  def matches? tagname, tagoptions = nil
    havetag =
      if tagoptions
        RSpecHtmlMatchers::HaveTag.new(tagname, tagoptions)
      else
        RSpecHtmlMatchers::HaveTag.new(tagname)
      end
    havetag.matches?(raw_code)
  end

  # Retourne true si la page définit l'ancre +ancre+
  def page_has_anchor? ancre
    self.matches?('a', with:{name: ancre}) || self.matches?('*', with: {id: ancre})
  end

  # Ancre contenue par la route
  def ancre_of_route
    @ancre_of_route ||= route.split('#').last
  end

  #
  def page_hors_site_valide?
    return true if route.match(/\.wikipedia\./)
    begin
      status_ok = html_status >= 200 && html_status <= 307
      raise if false == status_ok && route.start_with?('https')
    rescue Exception => e
      # Pour les routes https, il faut faire une vérification plus profonde
      # car elles peuvent ne pas renvoyer de
      # J'essaie d'abord avec une route sans s
      @route = route.sub(/^https/,'http')
      @html_status = nil
      retry
    end
    return status_ok
  end


  # Retourne true si l'url est valide dans sa forme et false
  # dans le cas contraire.
  # Renseigne @errors_format_url avec les problèmes rencontrés.
  def format_url_valide?
    @errors_format_url = Array.new
    if @route.match(/^("|'|“)/) || @route.match(/("|'|”)$/)
      @errors_format_url << "Mauvais guillemets autour de l'URL"
    end

    return @errors_format_url.count == 0
  end

end #/TestedPage
