# encoding: UTF-8
class User

  def first_post  ; @first_post   ||= get_first_post  end
  def last_post   ; @last_post    ||= get_last_post   end
  # Nombre de messages sur le forum
  def posts_count ; @posts_count  ||= get_posts_count end

  # Créer l'user dans la table du forum
  # Retourne les données enregistrées, car c'est la
  # procédure de récupération des données qui appelle
  # cette méthode.
  def create_in_forum
    Forum::table_users.insert(data_forum)
    data_forum
  end
  def data_forum
    {
      id:           id,
      posts_count:  0,
      first_post:   nil,
      last_post:    nil,
      created_at:   NOW,
      updated_at:   NOW
    }
  end

  # # Grade de l'auteur au format humain
  # # {String} Grade forum de l'utilisateur au format humain
  # def grade_humain
  #   @grade_humain ||= GRADES[grade][:hname]
  # end

  # Ajoute un message pour l'auteur
  # Cela correspond à plusieurs actions : incrémente la
  # donnée `count` de l'auteur (note : dans l'autre table),
  # renseigne `first_post` si c'est le premier message et
  # enfin renseigne `last_post` spécifiant l'identifiant
  # du dernier message.
  def add_post post_id
    post_id = post_id.id if post_id.instance_of?(Forum::Post)
    dnew = Hash::new
    # Est-ce un premier message ?
    dnew.merge!( first_post: { at:NOW, id:post_id } ) if posts_count == 0
    # On l'ajoute toujours en dernier message
    dnew.merge!(last_post: {at: NOW, id: post_id} )
    # On incrémente toujours le nombre de message de l'user
    @posts_count = posts_count + 1
    dnew.merge!( posts_count:@posts_count, updated_at:NOW )
    Forum::table_users.update(id, dnew)
  end

  def remove_post post_id
    post_id = post_id.id if ( post_id.instance_of? Forum::Post )
    dnew = Hash::new
    @posts_count = posts_count - 1
    dnew.merge!( posts_count:@posts_count )
    if first_post == post_id
      # Il faut rechercher le nouveau dernier message s'il existe
      res = Forum::table_posts.select( where:"id != #{post_id} AND user_id = #{id}", order:"created_at ASC", limit:1, colonnes: [] ).keys
      dnew.merge!( first_post: res.first ) # peut-être nil
    end
    if last_post == post_id
      res = Forum::table_posts.select( where:"id != #{post_id} AND user_id = #{id}", order:"created_at DESC", limit:1, colonnes: [] ).keys
      dnew.merge!( last_post: res.first ) # peut-être nil
    end
    Forum::table_users.update(id, dnew.merge( updated_at:NOW ))
  end



  private

    def get_posts_count
      data_forum_user[:posts_count]
    end
    def get_first_post
      data_forum_user[:first_post]
    end
    def get_last_post
      data_forum_user[:last_post]
    end
    def data_forum_user
      @data_forum_user ||= begin
        hdata = ( Forum::table_users.get id )
        hdata = create_in_forum if hdata.nil?
        hdata
      end
    end
end
