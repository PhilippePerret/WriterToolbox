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

    # Pour lister le nombre de citations par auteurs
    def nombre_citations_par_auteur
      request = "SELECT auteur, COUNT(auteur) as nombre_citations FROM citations GROUP BY auteur ORDER BY nombre_citations DESC;"

      'Classement des auteurs par nombre de citations'.in_h3 +
      site.dbm_base_execute(:cold, request).collect do |hauteur|
        auteur = hauteur[:auteur]
        auteur.match(/ dit /) && begin
          auteur = auteur.split(' dit ').last
        end
        auteur.length <= 30 || begin
          auteur = auteur[0..29] + ' […]'
        end
        auteur = auteur.ljust(34)
        nombre = hauteur[:nombre_citations].to_s.rjust(4)
        "#{auteur} #{nombre}"
      end.join("\n").in_pre
    end
  end #/<< self
end #/Citation
