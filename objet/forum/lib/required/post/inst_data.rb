# encoding: UTF-8
class Forum
class Post

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def user_id   ; @user_id    ||= get(:user_id)   end
  def sujet_id  ; @sujet_id   ||= get(:sujet_id)  end
  # Data dans autres tables
  def content   ; @content    ||= get_content     end
  def vote      ; @vote       ||= get_vote        end

  # Liste des IDs d'user ayant upvoté/downvoté
  def upvotes
    @upvotes || get_votes
    @upvotes
    end
  def downvotes
    @downvotes || get_votes
    @downvotes
  end
  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------

  def auteur      ; @auteur ||= User::get(user_id)          end
  def sujet       ; @sujet  ||= Forum::Sujet::get(sujet_id) end

  # ---------------------------------------------------------------------
  #   Méthodes de données
  # ---------------------------------------------------------------------

  # Actualisation du texte du message
  def update_content contenu
    new_data = {
      content:    contenu,
      updated_at: NOW
    }
    Forum::table_posts_content.update(id, new_data)
  end

  # ---------------------------------------------------------------------
  #   Private
  # ---------------------------------------------------------------------
  private
    def get_content
      Forum::table_posts_content.get(id, colonnes: [:content] )[:content]
    end

    def get_vote
      table_vote.get(id, colonnes: [:vote])[:vote].to_i
    end
    def get_votes
      d = table_vote.get(id, colonnes:[:upvotes, :downvotes, :vote])
      @upvotes    = d[:upvotes]
      @downvotes  = d[:downvotes]
      @vote       = d[:vote]
    end
end #/Post
end #/Forum
