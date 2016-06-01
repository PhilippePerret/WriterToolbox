# encoding: UTF-8
=begin

  SiteHtml::Updates Méthodes d'helper

=end
class SiteHtml
class Updates

  # Nombre maximum d'updates qu'il faut afficher dans
  # la page.
  NOMBRE_MAX_UPDATES_PER_PAGE = 50

  class << self

    def as_ul args = nil
      args ||= {}
      args[:from] ||= 0
      args[:to]   ||= args[:from] + NOMBRE_MAX_UPDATES_PER_PAGE
    end

  end #/<< self

end #/Updates
end #/SiteHtml
