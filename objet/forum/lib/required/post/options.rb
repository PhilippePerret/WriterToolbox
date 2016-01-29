# encoding: UTF-8
class Forum
class Post

  BIT_VALID = 0

  def options ; @options ||= get(:options) || "" end

  def bit_validation
    @bit_validation ||= options[BIT_VALID].to_i
  end
  def bit_validation= valeur
    @bit_validation = valeur
  end


end #/Post
end #/Forum
