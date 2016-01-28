# encoding: UTF-8
class User

  # Grade de l'auteur au format humain
  # {String} Grade forum de l'utilisateur au format humain
  def grade_humain
    @grade_humain ||= GRADES[grade][:hname]
  end

  # Le nombre de messages sur le forum
  def posts_count
    12 # pour le moment
    # @posts_count ||= Forum::table_users.select(where:{id: id}, colonnes:[:count]).values.first[:count]
  end

end
