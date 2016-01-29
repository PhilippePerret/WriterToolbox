# encoding: UTF-8

class ForumSpec
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

    # Former les données et les insérer dans
    # la table
    npd = new_post_data(params).dup
    contenu = npd.delete(:content)
    new_post_id = Forum::table_posts.insert( npd )

    # Ajouter le contenu dans la table
    # le contenant
    data_content = {
      id: new_post_id,
      content: contenu,
      updated_at: npd[:updated_at]
    }
    Forum::table_posts_content.insert(data_content)

    # Donner un vote aléatoire à ce message
    data_vote = {
      id: new_post_id,
      vote: rand(100),
      updated_at: npd[:updated_at]
    }
    Forum::table_posts_votes.insert(data_vote)

    # Ajouter ce post à son auteur
    User::get(npd[:user_id]).add_post( new_post_id )

    # Ajouter ce post à son sujet
    Forum::Sujet::get( npd[:sujet_id] ).add_post( new_post_id )

    # ON retourne l'id du nouveau post
    new_post_id

  end

  MOTS_ALEAS = ["gazelle", "crocodile", "chaudron", "philosophie", "marteau", "neige", "scénario"]
  NOMBRE_MOTS_ALEAS = MOTS_ALEAS.count

  # Retourne des données pour un nouveau message
  def new_post_data params
    bit_validation = case (params[:validation] || :valided)
    when :both
    when :valided     then 1
    when :not_valided then 0
    else rand(2) # :both ou rien
    end

    # puts "bit validation : #{bit_validation}"

    auteur  = ForumSpec::pick_any_user  # => User
    sujet   = ForumSpec::pick_any_sujet # => Forum::Sujet
    time    = NOW - rand(100).days
    # Pour la recherche par texte
    mot_alea = MOTS_ALEAS[rand(NOMBRE_MOTS_ALEAS)]
    npd = {
      user_id:      auteur.id,
      # Note : le content sera retiré pour le mettre dans la
      # table séparée qui le contient.
      content:      "Un nouveau message de #{auteur.pseudo} écrit le #{time.as_human_date} sur le sujet ##{sujet.id} parlant de #{mot_alea}.",
      sujet_id:     sujet.id,
      options:      "#{bit_validation}",
      updated_at:   time,
      created_at:   time
    }
    npd.merge!(valided_by: ForumSpec::pick_any_admin.id) if bit_validation == 1
    return npd
  end


end # << self
end #/Forum
