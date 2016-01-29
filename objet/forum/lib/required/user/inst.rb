# encoding: UTF-8
class User

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

  # Grade de l'auteur au format humain
  # {String} Grade forum de l'utilisateur au format humain
  def grade_humain
    @grade_humain ||= GRADES[grade][:hname]
  end

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
    dnew.merge!( posts_count: @posts_count )

    Forum::table_users.update(id, dnew)
  end

  # Le nombre de messages sur le forum
  def posts_count
    @posts_count ||= get_posts_count
  end

  private

    def get_posts_count
      data_forum_user[:posts_count]
    end
    def data_forum_user
      @data_forum_user ||= begin
        hdata = ( Forum::table_users.get id )
        hdata = create_in_forum if hdata.nil?
        hdata
      end
    end
end
