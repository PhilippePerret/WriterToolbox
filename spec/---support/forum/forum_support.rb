# encoding: UTF-8

class ForumSpec
  # Pour refaire le gel du forum avec messages
  # @usage: ForumSpec::make_gel_forum_with_messages
  def self.make_gel_forum_with_messages( quelconques = 50, non_valided = 5, nombre_users = 30)
    site.require_objet 'forum'
    Forum::table_users # simplement pour la construire avant
    # Forum::table_posts.delete(nil, true)
    @nombre_messages_quelconques = quelconques
    @nombre_messages_non_valided = non_valided
    ForumSpec::create_users(nombre_users)
    ForumSpec::create_posts(count: @nombre_messages_quelconques)
    ForumSpec::create_posts(count: @nombre_messages_non_valided, validation: :not_valided)
    @nombre_total_messages = @nombre_messages_quelconques + @nombre_messages_non_valided
    gel 'forum-with-messages'
  end
end
