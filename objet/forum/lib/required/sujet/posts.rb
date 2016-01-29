# encoding: UTF-8
class Forum
class Sujet

  # Retourne la liste des posts du sujet
  # (ou exceptionnellement un string UL si as: :ul)
  def posts params = nil
    params ||= Hash::new
    from_index  = params.delete(:from)  || 0
    for_nombre  = params.delete(:for)   || Forum::Sujet::nombre_by_default
    return_as   = params.delete(:as)    || :instance

    data_request = Hash::new
    data_request.merge!(
      where:    { sujet_id:  id },
      order:    "created_at ASC",
      offset:   from_index,
      limit:    for_nombre
    )

    # TODO : L'ordre (order) peut dépendre d'autres choses, par exemple
    # des votes qui sont dans la table posts_votes quand le sujet est d'un
    # type réponse à une question avec meilleure réponse.

    data_request.merge!(colonnes:[]) unless [:hash, :data].include?(return_as)

    # On relève les messages
    posts = Forum::table_posts.select(data_request)

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
    Forum::table_sujets_posts.update(id, {
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
      res = Forum::table_posts.select( where:"id != #{post_id} AND sujet_id = #{id}", order:"created_at DESC", limit:1, colonnes: [] ).keys
      data_update.merge!( last_post_id: res.first ) # peut-être nil
    end

    Forum::table_sujets_posts.update(id, data_update)
  end

end #/Sujet
end #/Forum
