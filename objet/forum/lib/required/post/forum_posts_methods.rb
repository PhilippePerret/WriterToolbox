# encoding: UTF-8
=begin

  Toutes les méthodes qu'on peut utiliser en faisant :

      forum.posts.<methode>


=end
class Forum
  def posts ; @posts ||= Post end

class Post
  class << self

    # {StringHTML} Retourne le div contenant les boutons
    # de navigation
    def navigation_bar toporbottom # :top ou :bottom
      (
        message_explication(toporbottom) +
        nav_button_back +
        nav_button_forward
      ).in_div(class:"nav_tools_bar #{toporbottom}")
    end
    def message_explication toporbottom
      return "" if toporbottom == :bottom
      "Trouvez ici tous les messages, tous sujets confondus, les derniers arrivés en premiers.".in_div(class:'fleft italic small')
    end
    def nav_button_back
      first_back =from - nombre_by_default
      (
        first_back.in_hidden(name:'posts_from') +
        "←".in_submit
      ).in_form(action:"post/list?in=forum", style:"visibility:#{first_back < 0 ? 'hidden' : 'visible'}")
    end
    def nav_button_forward
      first_forward = from + nombre_by_default
      (
        first_forward.in_hidden(name:'posts_from') +
        "→".in_submit
      ).in_form(action:"post/list?in=forum", style:"visibility:#{first_forward > nombre_total_messages ? 'hidden' : 'visible'}")
    end
    def from
      # TODO: Il ne faudra pas faire "nombre_by_default" mais prendre
      # le nombre de messages affichésd
      @from ||= param(:posts_from).to_i
    end

    def nombre_total_messages
      @nombre_total_messages ||= Forum::table_posts.count
    end

    # = main =
    #
    # Méthode principale pour récupérer des messages ou
    # un seul message (méthode get habituelle)
    # Retourne une liste {Array} d'instances Forum::Post ou
    # le message.
    #
    # La distinction se fait sur filter, qui peut être soit
    # un Fixnum (=> un seul message retourné) soit un filtre
    #
    # +filter+ {Hash} définissant le filtre à appliquer
    # Cf. where_clause_from pour le détail.
    # On peut définir notamment : :user_id, :created_after,
    # :created_before, :valid (true/false), :content (texte que
    # le message doit contenir)
    #
    def get filter = nil
      if filter.instance_of?( Fixnum )
        get_by_id(filter)
      else
        data_request = Hash::new
        unless filter.nil? || filter.empty?
          where, valeurs = Forum::where_clause_from(filter)
          data_request.merge!(where: where, values: valeurs)
        end
        data_request.merge!( colonnes: [:id] )
        # debug "data_request: #{data_request.inspect}"
        Forum::table_posts.select( data_request ).keys.collect do |pid|
          new(pid)
        end
      end
    end

    # Pour pouvoir utiliser la méthode `get` comme pour toutes
    # les autres classes.
    def get_by_id pid
      pid = pid.to_i
      @instances ||= Hash::new
      @instances[pid] ||= new(pid)
    end

    # = main =
    #
    # Retourne une liste Array des messages répondant
    # au filtre +params+
    # +params+
    #   <Toutes les valeurs possibles de filtre>
    #   +
    #   as:     :ids (default), :instance, :data, :li, :hash
    #           :li retourne un string de tous les titres de posts dans des LI
    #   from:   Depuis cet ID de message (0 par défaut, le dernier)
    #   for:    Pour ce nombre de messages Forum::Post::nombre_by_default
    #           par défaut
    def list params = nil
      params ||= Hash::new
      nombre_posts  = params.delete(:for)  || nombre_by_default
      return_as     = params.delete(:as)
      from_index   = params.delete(:from) || 0
      if from_index == :last
        from_index = param(:posts_from).to_i
      end

      data_request = Hash::new

      unless params.empty?
        params.merge!(valid: true)
        where, valeurs = Forum::where_clause_from(params)
        data_request.merge!(where: where, values: valeurs)
      end

      data_request.merge!(
        order:  'created_at DESC',
        offset: from_index,
        limit:  nombre_posts
      )

      # On a besoin que de l'identifiant s'il ne faut
      # pas retourner les données ou un hash des valeurs.
      data_request.merge!(colonnes: []) unless [:hash, :data].include?(return_as)

      # Cas spécial
      # -----------
      # NOTER que ce n'est pas ici qu'est traité le cas de l'affichage
      # d'une liste de messages d'un sujet. Cf. dans posts.rb d'un sujet
      #
      # Où on doit rechercher les posts d'un certain sujet de
      # type "Question technique". Dans ce cas, il faut utiliser
      # une jointure pour classer les messages.
      # Note : Ce système pourra être utiliser aussi plus tard si
      # on veut obtenir une liste de messages classés par votes
      if params[:sujet_id] && Forum::Sujet::get(params[:sujet_id]).type_s == 2
        debug "===> Relève sur sujet de type question technique"
        # Note : on doit utiliser "OUTER" car tous les posts n'ont
        # pas forcément de vote au moment où on fait la requête
        "SELECT id, vote"+
        " FORM posts"+
        " OUTER JOIN posts_votes"+
        " USING posts.id = posts_votes.id"+
        " WHERE sujet_id = #{sujet_id}"
      end
      # ----------------------------------------------
      # Relève des messages
      @posts = Forum::table_posts.select(data_request)
      # ----------------------------------------------

      case return_as
      when :instance, :instances  then @posts.keys.collect { |pid| get(pid) }
      when :li
        numero_message = from_index.to_i
        lis = @posts.keys.collect do |pid|
          numero_message += 1
          get(pid).as_li(as: :full_message, numero: numero_message)
        end.join('')
        lis = "Aucun message sur le forum pour le moment.".in_li if lis.empty?
        lis
      when :id, :ids, nil         then @posts.keys
      when :data                  then @posts.values
      when :hash                  then @posts
      end
    end

    # Retourne le nombre de messages répondant ou non au filtre
    # +filtre+ {Hash}
    #   user_id:          Que les messages de cet auteur
    #   created_after:    Les messages créés à ou après ce timestamp
    #   created_before:   Les messages créés à ou avant ce timestamp
    #   content:          Les messages contenant ce texte (recherche spéciale)
    def count filter = nil
      filter ||= Hash::new

      filtre_sur_texte = filter.delete(:content)

      data_request = unless filter.empty?
        where, valeurs = ( Forum::where_clause_from filter )
        { where: where, values: valeurs }
      else
        nil
      end

      if filtre_sur_texte.nil?
        # => Pas de recherche sur le texte
        return Forum::table_posts.count(data_request)
      elsif data_request.nil?
        # => Seulement une recherche sur le texte
        return Forum::table_posts_content.count(where:"content LIKE ?", values:["%#{filtre_sur_texte}%"])
      else
        # => Une recherche sur le texte et autre chose
        data_request ||= {where: "", values:[]}
        data_request[:where] += " AND " unless data_request[:where].empty?
        data_request[:where] += "posts_content.content LIKE ?"
        data_request[:values] << "%#{filtre_sur_texte}%"
        request = "SELECT posts_content.content" +
        # request = "SELECT COUNT(posts.id)" +
          " FROM posts" +
          " INNER JOIN posts_content" +
          " WHERE #{data_request[:where]}"
        BdD::execute_request(Forum::db.database, request, data_request[:values]).first.first
      end

    end

  end # << self
end #/Post
end #/Forum
