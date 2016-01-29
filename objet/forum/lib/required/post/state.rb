# encoding: UTF-8
class Forum
class Post

  # Retourne true si l'user courant est l'auteur du message
  def current_user_is_owner?
    user.id == user_id
  end

end #/Post
end #/Forum
