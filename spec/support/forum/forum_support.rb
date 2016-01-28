# encoding: UTF-8

# Pour refaire le gel du forum avec messages
def make_gel_forum_with_messages
  Forum::table_posts.delete(nil, true)
  @nombre_messages_quelconques = 50
  @nombre_messages_non_valided = 5
  Forum::create_posts(count: @nombre_messages_quelconques)
  Forum::create_posts(count: @nombre_messages_non_valided, validation: :not_valided)
  @nombre_total_messages = @nombre_messages_quelconques + @nombre_messages_non_valided
  gel 'forum-with-messages'
end
