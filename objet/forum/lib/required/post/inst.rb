# encoding: UTF-8
=begin
Extension de Forum::Message pour la gestion des messages
=end
class Forum
class Post

  include MethodesObjetsBdD

  # ID absolu du message dans la base de données du forum
  attr_reader :id

  # pid est nil à l'instanciation d'un nouveau message, par
  # exemple
  def initialize pid = nil
    @id = pid
  end

  def create d4create
    d4create.merge!(
      updated_at:   NOW,
      created_at:   NOW
    )
    contenu = d4create.delete(:content)
    @id = table.insert(d4create)
    d4create_content = {
      id:           @id,
      content:      contenu,
      updated_at:   NOW
    }
    table_content.insert(d4create_content)
  end

  def table         ; @table          ||= Forum::table_posts          end
  def table_content ; @table_content  ||= Forum::table_posts_content  end

end #/Post
end #/Forum
