# encoding: UTF-8
class Forum
class Sujet

  # Return true si le sujet courant est suivi par l'user
  # d'id +user_id+
  def followed_by?( user_id )
    followers.include? user_id
  end

  # {Array} Retourne la liste des IDs des users qui suivent
  # ce sujet.
  def followers
    @followers ||= begin
      res = table_follows.select(where: "sujet_id = #{id} AND user_id IS NULL", colonnes:[:items] )
      if res.empty?
        @followers_row_id = nil
        []
      else
        @followers_row_id = res.first[:id]
        res.first[:items].split(' ') || []
      end
    end
  end

  def followers_row_id ; @followers_row_id end

  # Sauvegarde la liste des suiveurs de ce sujet
  def save_followers
    if followers_row_id.nil?
      table_follows.insert(sujet_id:id, items: followers)
    else
      table_follows.update( @followers_row_id, {items:followers} )
    end
  end

  # Sauvegarde la liste +sujets_suivis+ des sujets suivis par
  # l'user +user_id+
  # TODO Normalement, cette méthode aurait plus à faire dans l'instance
  # User.
  def save_sujets_suivi user_id, sujets_suivis
    if following_row_id.nil?
      table_follows.insert(user_id: user_id, items: sujets_suivis)
    else
      table_follows.update(following_row_id, {items: sujets_suivis})
    end
  end

  # Retourne la liste des IDs des sujets suivis par +user_id+
  def followed_by user_id
    res = table_follows.select(where:"user_id = #{user_id} AND sujet_id IS NULL", colonnes:[:items])
    @following_row_id = res.first[:id]
    (@following_row_id.nil? ? nil : res.first[:items]) || []
  end

  def following_row_id ; @following_row_id end

  # Ajoute l'user +user_id+ à la liste des suiveurs de ce
  # sujet. Crée la liste si nécessaire.
  def add_follower user_id
    user_id = user_id.id if user_id.instance_of?(User)

    sujets_suivis = followed_by(user_id)

    unless followers.include?(user_id)
      @followers << user_id
      save_followers
    end

    unless sujets_suivis.include?(id)
      sujets_suivis << id.freeze
      save_sujets_suivi(user_id, sujets_suivis)
    end

  end

  # Retire un sujet suivi pour un auteur (pour l'auteur et pour
  # le sujet)
  def remove_follower user_id
    user_id = user_id.id if user_id.instance_of?(User)

    sujets_suivis = followed_by(user_id)

    if followers.include?(user_id)
      @followers.delete(user_id)
      save_followers
    end

    if sujets_suivis.include?(id)
      sujets_suivis = followed_by(user_id)
      sujets_suivis.delete(id)
      save_sujets_suivi(user_id, sujets_suivis)
    end
  end

  # Table contenu les informations de suivi
  def table_follows
    @table_follows ||= Forum.table_follows
  end

end #/Sujet
end #/Forum
