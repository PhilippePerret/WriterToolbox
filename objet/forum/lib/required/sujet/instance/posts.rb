# encoding: UTF-8
class Forum
class Sujet

  # Retourne la liste des posts du sujet
  # (ou exceptionnellement un string UL si as: :ul)
  def posts params = nil
    params ||= Hash::new
    from_index  = params.delete(:from)  || 0
    for_nombre  = params.delete(:for)   || Forum::Sujet.nombre_by_default
    return_as   = params.delete(:as)    || :instance



    # L'ordre (order) peut dépendre d'autres choses, par exemple
    # des votes qui sont dans la table posts_votes quand le sujet est d'un
    # type réponse à une question avec meilleure réponse.
    # On est contraint d'utiliser la jointure car :
    #   1. Les sujet_id sont dans la tables des posts
    #   2. Les votes sont dans la table des posts_votes
    #   3. Tous les messages n'ont pas forcément de votes.

    if type_s == 2

      # Un sujet de type "Question technique". Il faut classer les
      # messages par vote.
      # Note : On relève aussi `upvotes` pour pouvoir classer deux
      # messages qui ont la même note de vote mais contiennent des
      # nombre de votes différents (celui qui a le plus de votes
      # l'emporte, à note égale) - pas encore implémenté

      # Pour le moment, on ne prend que les ids car on relèvera
      # toutes les autres informations du me&@ssage en fonction de ce
      # qui est demandé
      colonnes = "posts.id, posts_votes.vote, posts_votes.upvotes"
      request = "SELECT #{colonnes}" +
      " FROM posts_votes"+
      " INNER JOIN posts" + # pour prendre même messages sans vote
      " ON posts.id = posts_votes.id"+
      " WHERE (posts.sujet_id = #{id})" +
      " ORDER BY vote DESC" +  # C'est pour ça qu'on utilise la jointure
      " LIMIT #{for_nombre}" +
      " OFFSET #{from_index};"

      # ---------------------------------------------
      # Relève des messages
      debug "request : #{request.inspect}"
      res_request = site.db_execute(:forum, request)
      debug "res_request : #{res_request.inspect}"
      # ---------------------------------------------
      # Note  : Seuls les messages qui possède un vote sont relevés.
      # debug res_request
      posts_ids = []
      posts     = {}
      res_request.each do |dres|
        p_id      = dres[:id]
        p_vote    = dres[:vote]
        p_upvotes = dres[:upvotes]
        posts_ids << p_id
        posts.merge!( p_id => {id: p_id} )
      end

      # Pour les questions techniques, on affiche toujours tous les
      # messages, on ne fonctionne pas en panneaux. Donc il faut récupérer
      # tous les messages du sujet qui n'ont pas reçu de votes et qui,
      # donc, ne font pas partie de la liste ci-dessus (s'il y a des
      # éléments dans la liste ci-dessus).

      if [:hash, :data].include?(return_as)
        # Si on demande à retourner les données, il faut relever
        # même les posts qui ont été trouvés avec un vote (ci-dessus)
        data_request = Hash.new
        if posts_ids.count > 0
          where_clause = "id IN (#{posts_ids.join(', ')})"
          data_request.merge! where: where_clause
        end
        data_request.merge!(colonnes:[]) unless [:hash, :data].include?(return_as)
        posts = Forum::table_posts.select(data_request)
      end

      # On finit par relever tous les posts qui n'ont pas de vote, en les
      # classant chronologiquement.
      data_request = Hash.new
      data_request.merge!( order: 'created_at DESC' )
      if posts_ids.count > 0
        where_clause = "id NOT IN (#{posts_ids.join(', ')}) AND sujet_id = #{id}"
        data_request = {where:where_clause}
      end
      data_request.merge!(colonnes:[]) unless [:hash, :data].include?(return_as)
      Forum.table_posts.select(data_request).each do |dpost|
        posts.merge! dpost[:id] => dpost
      end
      posts
    else

      # Un sujet de type forum, donc avec classement simple par date
      # de création.

      data_request = Hash::new
      data_request.merge!(
        where:    { sujet_id:  id },
        order:    "created_at ASC",
        offset:   from_index,
        limit:    for_nombre
      )
      data_request.merge!(colonnes:[]) unless [:hash, :data].include?(return_as)

      # ---------------------------------------------
      # Relève des messages
      posts = Forum::table_posts.select(data_request)
      # ---------------------------------------------
    end


    # On traite le retour en fonction de la demande
    case return_as
    when :instance  then posts.keys.collect{|pid| Forum::Post::get(pid)}
    when :id, :ids  then posts.keys
    when :data      then posts.values
    when :hash      then posts
    when :ul        then
      # Pour faire connaitre au message son index, pour qu'il
      # puisse le marquer dans le listing.
      post_numero = from_index.to_i
      posts.keys.collect do |pid|
        post_numero += 1
        Forum::Post::get(pid).as_li(as: :full_message, numero: post_numero)
      end.join.in_ul(id:"posts")
    end
  end

  # Ajoute le post d'ID +post_id+ au sujet courant
  def add_post post_id
    post_id = post_id.id if post_id.instance_of?(Forum::Post)
    @count        = count + 1
    @last_post_id = post_id
    Forum::table_sujets.update(id, {
      count:          @count,
      last_post_id:   post_id,
      updated_at:     NOW
    })
  end

  def remove_post post_id
    post_id = post_id.id if ( post_id.instance_of? Forum::Post )
    @count = count - 1
    data_update = {
      count:        @count,
      updated_at:   NOW
    }
    if last_post_id == post_id
      # Il faut rechercher le nouveau dernier message s'il existe
      res = Forum::table_posts.select( where:"id != #{post_id} AND sujet_id = #{id}", order:"created_at DESC", limit:1, colonnes: [])
      res_id = res.empty? ? nil : res.first[:id]
      data_update.merge!( last_post_id: res_id ) # peut-être nil
    end

    Forum.table_sujets.update(id, data_update)
  end

end #/Sujet
end #/Forum
