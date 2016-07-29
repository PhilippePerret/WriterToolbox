# encoding: UTF-8
class Page

  # Raccourci pour pouvoir faire `page.comments?`
  def comments?;  Comments.comments?  end
  def comments;   Comments.comments   end

  # ---------------------------------------------------------------------
  #   Class Page::Comments
  # ---------------------------------------------------------------------
  class Comments
    class << self

      # = main =
      #
      # Retourne la section des commentaires de page
      #
      # La vue se trouve dans ./view/deep/deeper/gabarit/comments.erb
      #
      def comments
        Vue.new('comments', site.folder_gabarit).output
      end

      # = main =
      #
      # Retourne true s'il faut activer les commentaires sur la
      # page courante.
      #
      # @usage      page.comments?
      def comments?
        @comments_on === true
      end

      # Réinitialisation des valeurs après un changement
      def reset
        app.session['nombre_total_page_comments'] = nil
        @nombre_commentaires = nil
      end


      def set_comments_on
        @comments_on = true
      end

      def set_comments_off
        @comments_on = false
      end


      def path_vue
        @path_vue ||= site.folder_gabarit + 'comments.erb'
      end

      def table
        @table ||= site.dbm_table(:cold, 'page_comments')
      end
    end #/<<self
  end #/Comments
end #/Page
