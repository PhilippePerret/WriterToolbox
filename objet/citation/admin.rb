# encoding: UTF-8
raise_unless_admin

class Citation
  class << self

    def ul_citations_sans_explicitation
      'Citations sans explicitation'.in_h3 +
      citations_sans_explicitation(5).collect do |hcitation|
        href = "citation/#{hcitation[:id]}/edit"
        "[##{hcitation[:id]}] #{hcitation[:citation]}".in_a(href: href, target: :new).in_li(class: 'citation')
      end.join('').in_ul(id: 'citations_sans_explicitations')
    end

    def citations_sans_explicitation nombre = 5
      drequest = {
        where: "description IS NULL OR description = ''",
        limit: 5,
        colonnes: [:citation]
      }
      table_citations.select(drequest)
    end
  end #/<< self
end #/Citation
