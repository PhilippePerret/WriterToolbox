# encoding: UTF-8
class User

  # Cette méthode existe dans le programme UN AN UN SCRIPT, mais
  # pour ne pas être obligé de charger l'objet quand ça n'est pas
  # indispensable, on crée cette méthode qui sera surclassée par
  # l'autre
  def unanunscript?
    return false unless user.identified?
    table_programs = site.db.create_table_if_needed('unan_hot', 'programs')
    table_programs.count(where:"(auteur_id = #{user.id}) AND (options LIKE '1%') AND (options NOT LIKE '__1%')" ) > 0
  end
end #/User
