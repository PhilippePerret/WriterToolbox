# encoding: UTF-8
class Forum
class Sujet

  def followed_by? user_id
    followers.include? user_id
  end

  def followers
    @followers ||= begin
      res = table_follow.get(where:{sujet_id: id}, colonnes:[:items_ids] )
      @followers_doesnt_exist = !!res.nil?
      (res.nil? ? nil : res[:items_ids]) || Array::new
    end
  end

  # Sauvegarde la liste des suiveurs de ce sujet
  def save_followers
    if @followers_doesnt_exist
      table_follow.insert(sujet_id:id, items_ids:followers)
    else
      table_follow.set(values:{items_ids:followers}, where:{sujet_id:id})
    end
  end

  # Sauvegarde la liste +sujets_suivis+ des sujets suivis par
  # l'user +user_id+
  # TODO Normalement, cette méthode aurait plus à faire dans l'instance
  # User.
  def save_sujets_suivi user_id, sujets_suivis
    if @followed_by_doesnt_exist
      table_follow.insert(user_id:user_id, items_ids:sujets_suivis)
    else
      table_follow.set(values:{items_ids:sujets_suivis}, where:{user_id:user_id})
    end
  end

  # Retourne la liste des IDs des sujets suivis par +user_id+
  def followed_by user_id
    suivis = table_follow.get(where:{user_id: user_id}, colonnes:[:items_ids])
    @followed_by_doesnt_exist = !!suivis.nil?
    (suivis.nil? ? nil : suivis[:sujets_suivis]) || Array::new
  end


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
  def table_follow
    @table_follow ||= Forum::table_sujets_followers
  end

end #/Sujet
end #/Forum
