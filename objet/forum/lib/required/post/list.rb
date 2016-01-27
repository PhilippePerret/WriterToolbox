# encoding: UTF-8
=begin
Extension du singleton Forum pour l'affichage des messages
=end
class Forum

  def posts
    @posts ||= Post
  end

  class Post
    # ---------------------------------------------------------------------
    #   Class Forum::Post (tous les messages)
    # ---------------------------------------------------------------------
    class << self
      def as_list
        Forum::Sujet::all.collect do |sid, isujet|
          (isujet.as_titre_in_listing_posts + isujet.listing_posts).in_div(class:'topic', id:"topic-#{sid}")
        end.join('')
      end
      def table_messages
        @table_messages ||= site.db.create_table_if_needed('forum', 'posts')
      end
    end
  end # / Message
end # / Forum
