# encoding: UTF-8
=begin

  Module permettant de lister tous les commentaires de page
  Notamment pour les valider

=end
class Page
  class Comments
    class << self

      # Code UL de la liste des commentaires non validés
      def ul_comments_non_valided
        user.admin? || (return '') # au cas où
        table.select(where: 'SUBSTRING(options,1,1) = "0"').collect do |hcom|
          new(hcom).as_li
        end.join('').in_ul(id: 'ul_comments_non_valided', class: 'ul_page_comments')
      end
      def nombre_comments_non_valided
        table.count(where: 'SUBSTRING(options,1,1) = "0"')
      end
      def nombre_comments_valided
        table.count(where: 'SUBSTRING(options,1,1) = "1"')
      end

      def ul_comments_valided args = nil
        args ||= Hash.new
        args[:from] ||= 0
        args[:to]   ||= 50
        nombre =
          if args[:to]
            args[:to] - args[:from]
          else
            args[:nombre]
          end
        debug "Nombre : #{nombre}"
        table.select(where: 'SUBSTRING(options,1,1) = "1"', offset: args[:from], limit: nombre).collect do |hcom|
          new(hcom).as_li
        end.join('').in_ul(id: 'ul_comments_valided', class: 'ul_page_comments')
      end

    end #/<< self
  end #/Comments
end #/Page
