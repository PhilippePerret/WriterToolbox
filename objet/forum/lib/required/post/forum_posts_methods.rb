# encoding: UTF-8
=begin

  Toutes les méthodes qu'on peut utiliser en faisant :

      forum.posts.<methode>


=end
class Forum
  def posts ; @posts ||= Post end

class Post
  class << self

    def as_list params
      liste_lis = list(params).strip
      liste_lis.empty? ? "Aucun message dans le forum pour le moment".in_li : liste_lis
    end

    # +params+
    #   as:     :ids (default), :instance, :data, :li
    #           :li retourne un string de tous les titres de posts dans des LI
    #   from:   Depuis cet ID de message (0 par défaut, le dernier)
    #   for:    Pour ce nombre de messages Forum::Post::nombre_by_default
    #           par défaut
    def list params = nil
      params ||= Hash::new
      nombre_posts = params.delete(:for)  || nombre_by_default
      from_indice  = params.delete(:from) || 0

      data_request = {
        where:  "options LIKE '1%'",
        order:  'created_at DESC',
        offset: from_indice,
        limit:  nombre_posts
      }
      return_as = params.delete(:as)
      data_request.merge!(colonnes: []) if return_as != :data

      # On relève les messages
      @posts = Forum::table_posts.select(data_request).keys

      case return_as
      when :instance, :instances  then @posts.collect { |pid| get(pid) }
      when :data                  then @posts
      when :li                    then @posts.collect { |pid| get(pid).as_li }.join('')
      when :id, :ids, nil         then @posts
      end
    end

    # Retourne un Array dont le premier élément est la
    # clause WHERE (avec des "?") et le second élément est
    # la liste Array des valeurs des points d'interrogation
    def where_clause_from filter
      return [nil, nil] if filter.nil?
      arr_where   = Array::new
      arr_values  = Array::new
      if filter[:user_id]
        arr_where   << "user_id = ?"
        arr_values  << filter[:user_id]
      end
      if filter[:created_after]
        arr_where   << "created_at >= ?"
        arr_values  << filter[:created_after]
      end
      if filter[:created_before]
        arr_where   << "created_at < ?"
        arr_values  << filter[:created_before]
      end
      if filter.has_key?(:valid)
        arr_where   << "options LIKE ?"
        arr_values  << (filter[:valid] ? '1%' : '0%')
      end
      if filter[:content]
        arr_where   << "content LIKE ?"
        arr_values  << "%" + filter[:content].gsub(/</,'&lt;').gsub(/>/,'&gt;') + "%"
      end

      [arr_where.join(' AND '), arr_values]
    end

    # Retourne le nombre de messages répondant ou non au filtre
    # +filtre+ {Hash}
    #   user_id:          Que les messages de cet auteur
    #   created_after:    Les messages créés à ou après ce timestamp
    #   created_before:   Les messages créés à ou avant ce timestamp
    def count filter = nil
      data_request = unless filter.nil?
        where, valeurs = ( where_clause_from filter )
        { where: where, values: valeurs }
      else
        nil
      end

      Forum::table_posts.count(data_request)

    end

  end # << self
end #/Post
end #/Forum
