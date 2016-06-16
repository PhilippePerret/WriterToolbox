# encoding: UTF-8
class User

  # Cette méthode existe dans le programme UN AN UN SCRIPT, mais
  # pour ne pas être obligé de charger l'objet quand ça n'est pas
  # indispensable, on crée cette méthode qui sera surclassée par
  # l'autre
  def unanunscript?
    user.identified? || ( return false )
    where = []
    where << "auteur_id = #{user.id}"
    where << 'options LIKE "1%"'
    where << 'options NOT LIKE "__1%"'
    where = where.join(' AND ')
    site.dbm_table(:unan, 'programs').count(where: where) > 0
  end
end #/User
