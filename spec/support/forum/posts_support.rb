# encoding: UTF-8

class Forum
class << self
  # +params+
  #   :count        Nombre de messages à créer
  #   :validation   Soit :valided (les messages doivent tous être validés),
  #                 soit :not_valided (messages tous non validés),
  #                 ou :both (des messages validés et des non validés)
  #
  # Return la liste des IDs des nouveaux messages
  def create_posts params
    params ||= Hash::new
    params[:count] ||= 10

    ids_new_posts = Array::new
    params.delete(:count).times do |itime|
      ids_new_posts << create_new_post(params)
    end

    return ids_new_posts
  end

  # +params+ pour :
  #   :validation
  def create_new_post params
    npd = new_post_data(params).dup
    new_post_id = Forum::table_posts.insert( npd )
    sujet = Forum::Sujet::get( npd[:sujet_id] )
    sujet.add_post( new_post_id )
    new_post_id
  end

  # Retourne des données pour un nouveau message
  def new_post_data params
    bit_validation = case params.delete(:validation)
    when :both
    when :valided then 1
    when :not_valided then 0
    else rand(1) # :both ou rien
    end

    auteur  = pick_any_user  # => User
    sujet   = pick_any_sujet # => Forum::Sujet
    time    = NOW - rand(100).days
    npd = {
      user_id:      auteur.id,
      content:      "Contenu du message du #{Time.now}, un message de #{auteur.pseudo} sur le sujet #{sujet.name}.",
      sujet_id:     sujet.id,
      options:      "#{bit_validation}",
      updated_at:   time,
      created_at:   time
    }
    npd.merge!(valided_by: pick_any_admin.id) if bit_validation == 1
    return npd
  end


end # << self
end #/Forum
