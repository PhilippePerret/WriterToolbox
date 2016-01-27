# encoding: UTF-8
class Forum
  include Singleton
  def self.bind; binding() end
  def bind; binding() end
end

# Pour le singleton
# Permet d'utiliser `forum. ...` dans les vues du forum
def forum
  @forum ||= Forum.instance
end
