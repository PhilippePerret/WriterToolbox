# encoding: UTF-8
=begin

  Les commentaires en tant que liste

=end
class Page
class Comments
  class << self

    # = main =
    #
    # Retourne le code Html UL pour la liste des commentaires, ou
    # simplement le commentaire "Aucun commentaire pour le moment."
    def ul_current_route_comments
      allcoms = current_route_comments
      if allcoms.empty?
        'Cette page n’a fait l’objet d’aucun commentaire pour le moment.'.in_div(id: 'div_no_page_comment')
      else
        current_route_comments.collect do |comment|
          comment.as_li
        end.join.in_ul(id: 'ul_page_comments')
      end
    end

    # Les commentaires de la route courante
    # Retourne une liste Array d'instance Page::Comments de ces
    # commentaires.
    #
    # Noter que pour un visiteur non administrateur, on ne prend
    # que les commentaires qui ont été validés.
    #
    def current_route_comments
      whereclause = "route = '#{site.current_route.route}'"
      user.admin? || whereclause += " AND SUBSTRING(options,1,1) = '1'"
      drequest = {
        where: whereclause,
        order: 'created_at DESC'
      }
      table.select(drequest).collect do |hcomment|
        new(hcomment)
      end
    end

    def table
      @table ||= site.dbm_table(:cold, 'page_comments')
    end

  end #/<< self

end #/Comments
end #/Page
