# encoding: UTF-8
=begin
Extension du singleton Forum pour l'affichage des messages
=end
class Forum

  def messages
    @messages ||= Message
  end

  class Message
    # ---------------------------------------------------------------------
    #   Class Forum::Message (tous les messages)
    # ---------------------------------------------------------------------
    class << self
      def as_list
        Forum::Sujet::all.collect do |sid, isujet|
          (isujet.as_titre_in_listing_messages + isujet.listing_messages).in_div(class:'topic', id:"topic-#{sid}")
        end.join('')
      end
      def table_messages
        @table_messages ||= site.db.create_table_if_needed('forum', 'messages')
      end
    end
    # ---------------------------------------------------------------------
    #   Instance Forum::Message (un message en particulier)
    # ---------------------------------------------------------------------
    def initialize

    end
  end # / Message
end # / Forum
