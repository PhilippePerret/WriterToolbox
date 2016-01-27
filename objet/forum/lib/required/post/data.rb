# encoding: UTF-8
class Forum
class Post

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def user_id   ; @user_id  ||= get(:user_id)   end
  def sujet_id  ; @sujet_id ||= get(:sujet_id)  end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------

  def auteur      ; @auteur ||= User::get(user_id)          end
  def sujet       ; @sujet  ||= Forum::Sujet::get(sujet_id) end

end #/Post
end #/Forum
