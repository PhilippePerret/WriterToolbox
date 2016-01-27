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


    def count filter = nil
      Forum::table_posts.count()
    end

  end # << self
end #/Post
end #/Forum
