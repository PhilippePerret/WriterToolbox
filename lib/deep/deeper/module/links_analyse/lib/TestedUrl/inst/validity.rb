# encoding: UTF-8
=begin
  Module de méthodes checkant la validité de la page
=end
class TestedUrl

  # Méthode principale checkant la validité de la
  # page.
  # Il faut définir la méthode check_if_valide dans le module
  # app.rb pour chaque application
  def valide?
    if @is_valide === nil
      if ancre?
        # Check d'une ancre seule. Le code de la page doit posséder
        # l'ancre spécié, soit sous forme d'un <a name> soit sous forme
        # d'élément d'identifiant correspondant à l'ancre.
        @is_valide = referer.page_has_anchor?(ancre_of_route)
        if false == @is_valide
          error "ANCRE INTROUVABLE : #{ancre_of_route.inspect}"
          puts "code : #{referer.raw_code}"
        end
      elsif hors_site?
        # Pour une page hors site, il suffit que l'header retourne
        # un code correct, donc 200 ou 3xx pour que ce soit bon
        @is_valide = page_hors_site_valide?
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
  #
  def ancre_of_route
    @ancre_of_route ||= route.split('#').last
  end


  def page_hors_site_valide?
    html_status >= 200 && html_status <= 307
  end

end #/TestedUrl
