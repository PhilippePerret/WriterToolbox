# encoding: UTF-8
class Forum
class Post

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def user_id   ; @user_id  ||= get(:user_id)   end
  def sujet_id  ; @sujet_id ||= get(:sujet_id)  end
  # Data dans autres tables
  def content   ; @content  ||= get_content     end
  def vote      ; @get_vote ||= get_vote        end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------

  def auteur      ; @auteur ||= User::get(user_id)          end
  def sujet       ; @sujet  ||= Forum::Sujet::get(sujet_id) end


  # ---------------------------------------------------------------------
  #   Private
  # ---------------------------------------------------------------------
  private
    def get_content
      Forum::table_posts_content.get(id, colonnes: [:content] )[:content]
    end

    def get_vote
      Forum::table_posts_votes.get(id, colonnes: [:vote])[:vote]
    end
end #/Post
end #/Forum
