# encoding: UTF-8
class Forum
class << self

  # Note : il faut une procédure spéciale pour pouvoir
  # créer des auteurs qui peuvent écrire des messages
  # +params+ {Hash}
  #   grade_min:    {Fixnum de 0 à 9}, le grade minimum
  #   admin:
  def create_new_auteur params = nil
    params ||= Hash::new
    params[:grade_min] ||= 4
    bit2 = params[:grade_min] + rand(9 - params[:grade_min])
    opts = "0#{bit2}"
    create_user(options: opts, session_id:nil)
  end


  # Retourne un auteur au hasard (instance {User})
  def pick_any_user
    User::get(shuffled_user_ids.shuffle!.shuffle!.first)
  end
  alias :get_any_user   :pick_any_user
  alias :get_any_auteur :pick_any_user

  # Retourne un administrateur (grade > 6)
  def pick_any_admin
    User::get(shuffled_admin_ids.shuffle!.shuffle!.first)
  end
  alias :get_any_admin :pick_any_admin

  def shuffled_user_ids
    @shuffled_user_ids ||= begin
      if all_auteurs_ids.count < 10
        (10 - all_auteurs_ids.count).times do create_new_auteur end
        reset_auteurs
      end
      all_auteurs_ids.dup
    end
  end
  def shuffled_admin_ids
    @shuffled_admin_ids ||= begin
      if all_admins_ids.count < 5
        (5 - all_admins_ids.count).times do create_new_auteur(grade_min: 7) end
        reset_auteurs
      end
      all_admins_ids.dup
    end
  end

  def all_auteurs_ids
    @all_auteurs_ids ||= begin
      ids = User::table.select(colonnes:[:id, :options]).values.collect do |huser|
        next nil if huser[:options][1].to_i < 4
        huser[:id]
      end.compact
    end
  end
  def all_auteurs
    @all_auteurs ||= begin
      all_auteurs_ids.each { |uid| User::get(uid) }
    end
  end

  def all_admins_ids
    @all_admins_ids ||= begin
      ids = User::table.select(colonnes:[:id, :options]).values.collect do |huser|
        next nil if huser[:options][1].to_i < 6
        huser[:id]
      end.compact
    end
  end
  def all_admins
    @all_admins ||= begin
      all_admins_ids.each { |uid| User::get(uid) }
    end
  end

  def reset_auteurs
    [:all_auteurs_ids, :all_auteurs, :all_admins_ids, :all_admins].each do |k|
      instance_variable_set("@#{k}", nil)
    end
  end

end # << self
end # /Forum
