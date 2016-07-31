# encoding: UTF-8
class TestedUrl
  class Link

    # Index du lien dans la page
    attr_reader :index

    # Instance NokogiriXMLElement
    attr_reader :nokoxmlelement

    # Instanciation à partir du lien brut tel qu'écrit dans le
    # code de la page HTML
    def initialize nokoxmlelement, ilink
      @nokoxmlelement = nokoxmlelement
      @index          = ilink
    end

    # Le texte du lien
    def text
      @text ||= nokoxmlelement.inner_html
    end

    # L'attribut HREF du lien
    def href
      @href ||= nokoxmlelement.attr('href')
    end

    # Retourne true si c'est un lien javascript (donc ne conduisant pas,
    # a priori, à une page)
    def javascript?
      @is_void = (href == 'javascript:void(0)') if @is_void === nil
      @is_void
    end

  end #/Link
end #/TestedUrl
