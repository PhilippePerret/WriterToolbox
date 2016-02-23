# encoding: UTF-8
=begin

  Toutes les méthodes qu'on peut utiliser en faisant :

      forum.sujets.<methode>


=end
class Forum
  def sujets ; @sujets ||= Sujet end

class Sujet
  class << self

    # Retourne [where_clause, where_values]
    # Cf. dans class.rb de Forum
    def where_clause_from filter = nil
      Forum::where_clause_from filter
    end

    # Retourne l'instance Forum::Sujet d'ID +sid+ en la prenant
    # dans la liste des instances déjà instanciées ou en créant
    # l'instance.
    def get sid
      sid = sid.to_i
      @instances      ||= Hash::new
      @instances[sid] ||= ( new sid )
    end

    # = main =
    #
    # Pour obtenir une liste de sujets conformément aux paramètres
    # +params+
    #   <toutes les données de filtre>
    #   +
    #   as:     Type de retour, :instance, :id (défaut), :hash, :data
    #   from:   Depuis cet index
    #   for:    Pour ce nombre d'éléments
    #
    def list params = nil
      params ||= Hash::new
      return_as   = params.delete(:as)    || :id
      for_nombre  = params.delete(:for)   || nombre_by_default
      from_index  = params.delete(:from)  || 0
      if from_index == :last
        from_index = 0 # pour le moment. Après, on le lira dans les paramètres
      end


      data_request = Hash::new

      unless params.empty?
        where, valeurs = ( where_clause_from params )
        data_request.merge!(where: where, values: valeurs)
      end

      # Paramètres de la requête
      data_request.merge!(
        order:    "categories ASC, created_at DESC",
        limit:    for_nombre,
        offset:   from_index
      )
      colonnes = [:id] unless [:data, :hash].include?(return_as)
      data_request.merge!(colonnes: colonnes)

      @hash_sujets = Forum::table_sujets.select(data_request)

      case return_as
      when :id, :ids, nil  then @hash_sujets.keys
      when :hash      then @hash_sujets
      when :data      then @hash_sujets.values
      when :instance  then @hash_sujets.keys.collect { |sid| get(sid) }
      when :li        then
        if @hash_sujets.empty?
          "Aucun sujet sur le forum pour le moment.".in_li
        else
          @hash_sujets.keys.collect { |sid| get(sid).as_li }.join('')
        end
      end
    end

  end # << self
end #/Sujet
end #/Forum
