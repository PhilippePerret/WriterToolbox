# encoding: UTF-8
=begin
Extension de Forum::Message pour la gestion des messages
=end
class Forum
class Post

  include MethodesObjetsBdD

  # ID absolu du message dans la base de données du forum
  attr_reader :id

  def initialize pid
    @id = pid
  end

  def table ; @table ||= Forum::table_posts end
  
end #/Post
end #/Forum
