# encoding: UTF-8
class User

  # Cette méthode existe dans le programme ÉCRIRE UN FILM/ROMAN EN UN AN, mais
  # pour ne pas être obligé de charger l'objet quand ça n'est pas
  # indispensable, on crée cette méthode qui sera surclassée par
  # l'autre
  def unanunscript?
    user.identified? || ( return false )
    if @is_unanunscript === nil
      where = []
      where << "auteur_id = #{user.id}"
      where << 'options LIKE "1%"'
      where << 'options NOT LIKE "__1%"'
      where = where.join(' AND ')
      @is_unanunscript = site.dbm_table(:unan, 'programs').count(where: where) > 0
    end
    @is_unanunscript
  end
end #/User
