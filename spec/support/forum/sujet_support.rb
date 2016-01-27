# encoding: UTF-8
class Forum
class << self

  # Retourne un sujet au hasard (instance {Forum::Sujet})
  def pick_any_sujet
    Forum::Sujet::get(shuffled_sujets_ids.shuffle!.shuffle!.first)
  end
  alias :get_any_sujet :pick_any_sujet

  # Crée un sujet et retourne son instance
  # Retourne l'IDentifiant du nouveau sujet
  def create_new_sujet
    Forum::table_sujets.insert( data_new_sujet )
  end
  def data_new_sujet
    creator = pick_any_user
    {
      creator_id: creator.id,
      name:       "Nom du sujet de #{creator.pseudo} à #{Time.now}",
      last_message:   nil,
      count:          0,
      options:        "",
      categories:     nil,
      created_at:     NOW,
      updated_at:     NOW
    }
  end


  def shuffled_sujets_ids
    @shuffled_sujets_ids ||= begin
      # Sil y a moins de 10 sujets, en créer jusqu'à 10
      if all_sujets.count < 10
        (10 - all_sujets.count).times do create_new_sujet end
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
  def all_sujets_ids
    @all_sujets_ids ||= Forum::table_sujets.select(colonnes:[]).keys
  end

  def reset_sujets
    [:all_sujets, :all_sujets_ids].each do |k|
      instance_variable_set("@#{k}", nil)
    end
  end

end # << self
end #/Forum
