# encoding: UTF-8
class ForumSpec
class << self

  # Retourne un sujet au hasard (instance {Forum::Sujet})
  # +options+ {hash} d'options
  #   type:   1 (sujet de type forum) ou 2 (sujet de type question technique)
  #   with_messages:  Si true, le sujet doit avoir des messages
  def get_any_sujet options = nil
    Forum::Sujet::get(shuffled_sujets_ids(options).shuffle!.shuffle!.first)
  end
  alias :pick_any_sujet :get_any_sujet

  # Crée un sujet et retourne son instance
  # Retourne l'IDentifiant du nouveau sujet
  def create_new_sujet
    new_sujet_id = Forum::table_sujets.insert( data_new_sujet )
  end
  def data_new_sujet
    time = NOW - rand(100).days
    creator = pick_any_admin
    mot_alea = MOTS_ALEAS[rand(NOMBRE_MOTS_ALEAS)]
    {
      creator_id:     creator.id,
      name:           "Un sujet initié par #{creator.pseudo} à #{time.as_human_date} à propos de #{mot_alea}",
      options:        "",
      categories:     nil,
      id:             id,
      last_post_id:   nil,
      count:          0,
      views:          0,
      created_at:     time,
      updated_at:     time
    }
  end


  def shuffled_sujets_ids(options = nil)
    @shuffled_sujets_ids ||= begin
      # Sil y a moins de 10 sujets, en créer jusqu'à 10
      if all_sujets_ids(options).count < 10
        (10 - all_sujets_ids.count).times do create_new_sujet end
        reset_sujets
      end
      all_sujets_ids.dup
    end
  end


  # {Array de Forum::Sujet}
  def all_sujets
    @all_sujets ||= begin
      all_sujets_ids.collect{|sid| Forum::Sujet::get(sid)}
    end
  end
  # {Array de Fixnum} Liste de tous les ID de sujet
  def all_sujets_ids(options = nil)
    if options.nil?
      @all_sujets_ids ||= begin
        Forum::table_sujets.select(colonnes:[:id]).keys
      end
    else
      # Un filtre est défini par +options+
      type = options.delete(:type)
      where_clause = Array::new
      where_clause << "options LIKE '_#{type}%'" if type
      where_clause = where_clause.join(' AND ')
      ids = Forum::table_sujets.select(colonnes:[:id], where: where_clause).keys

      if options[:with_messages]
        # On ne doit retourner que les sujets qui possèdent des messages
        ids = ids.select do |sid|
          Forum::table_posts.count(where:"sujet_id = #{sid}") > 0
        end
      end

      return ids
    end
  end

  def reset_sujets
    [:all_sujets, :all_sujets_ids].each do |k|
      instance_variable_set("@#{k}", nil)
    end
  end

end # << self
end #/Forum
