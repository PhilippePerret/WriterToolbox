# encoding: UTF-8
class User

  # # Méthode qui retourne true si l'user courant peut être
  # # considéré comme un visiteur autorisé.
  # # Les visiteurs autorisés sont :
  # #   - les abonnés
  # #   - les auteurs du programmes un an un script
  # #   - les icariens actifs
  # #   - les administrateurs
  # def authorized?
  #   subscribed? || unanunscript? || icarien_actif? || admin?
  # end

  # Cette méthode existe dans le programme UN AN UN SCRIPT, mais
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
