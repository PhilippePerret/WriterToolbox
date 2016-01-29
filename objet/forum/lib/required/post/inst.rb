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

  def create d4create = nil
    d4create ||= data4create
    d4create.merge!(
      updated_at:   NOW,
      created_at:   NOW
    )
    contenu = d4create.delete(:content).to_s # vide au départ
    @id = table.insert(d4create)
    contenu = contenu.gsub(/\r/,'') if contenu.match(/\n/)
    d4create_content = {
      id:           @id,
      content:      contenu,
      updated_at:   NOW
    }
    table_content.insert(d4create_content)
  end

  # Effacer le message
  def delete
    sujet.remove_post id
    auteur.remove_post id
    (table.delete         id)
    (table_content.delete id)
    (table_vote.delete    id)
  end

  def upvote
    return error "Vous avez déjà plébiscité ce message." if upvotes.include?(user.id)
    vote
    data_vote = Hash::new
    if downvotes.include?(user.id)
      downvotes.delete(user.id)
      data_vote.merge!(downvotes: downvotes)
      @vote += 1
    end
    upvotes << user.id
    @vote += 1
    data_vote.merge!( upvotes:upvotes, vote:vote )
    ( set_vote data_vote )
  end
  def downvote
    return error "Vous avez déjà désapprouvé ce message." if downvotes.include?(user.id)
    vote
    data_vote = Hash::new
    if upvotes.include?(user.id)
      upvotes.delete(user.id)
      data_vote.merge!(upvotes: upvotes)
      @vote -= 1
    end
    downvotes << user.id
    @vote -= 1
    data_vote.merge!(downvotes: downvotes, vote: vote)
    ( set_vote data_vote )
  end
  def set_vote data_vote
    data_vote.merge!( updated_at:NOW )
    if table_vote.count(where:{id: id}) > 0
      table_vote.update(id, data_vote)
    else
      table_vote.insert(data_vote.merge(id: id))
    end
    flash "Merci pour votre vote."
    return true
  end

  def table         ; @table          ||= Forum::table_posts          end
  def table_content ; @table_content  ||= Forum::table_posts_content  end
  def table_vote    ; @table_vote     ||= Forum::table_posts_votes    end

end #/Post
end #/Forum
