# encoding: UTF-8
class User

  RAISONS_DESTROY = [
    "Je n'ai plus le temps d'écrire",
    "Je n'ai plus rien à apprendre du BOA",
    "Ce site ne me plait pas du tout",
    "J'ai renoncé à l'écriture"
  ]

  # Procédure complète de destruction du compte de l'user
  # Note : Elle ne s'appelle pas `destroy` car elle serait directement
  # appelée par la route.
  def exec_destroy
    raise "Pirate !" if user.id != site.current_route.objet_id
    raise "Opération impossible." if dkill[:confirmation_destroy] != '1'
    raise "Impossible de te détruire, Phil" if user.id == 1
    raise "Impossible de vous détruire, Marion" if user.id == 3
    @data_killed = {
      pseudo: user.pseudo.freeze,
      id:     user.id.freeze
    }
    destroy_messages_forum
    destroy_programmes_unan
    deconnecte_user
    remove # méthode générale qui détruit le dossier et la donnée dans la base
    flash "Vous avez été détruit avec succès, #{@data_killed[:pseudo]}. Au regret de vous voir partir…"
    redirect_to :home
  rescue Exception => e
    debug e
    error e.message
    return false
  else
    return true
  end

  def dkill
    @dkill ||= param(:destroy) || Hash::new
  end

  def deconnecte_user
    debug "  * Déconnexion de l'user courant"
    deconnexion
    debug "  = User déconnecté"
  end

  # Destruction de l'user
  # (en fait, on le marque simplement détruit)
  # Ça détruit également son dossier de data s'il en a
  # un dans l'application
  def destroy_in_database_users
    debug "  * Destruction de l'user dans la base de données"
    user.remove
    debug "  = User détruit dans la base de données"
  end

  # Destruction des messages forum
  # (en fait, on marque que l'user a supprimé son compte mais on
  #  garde le message)
  def destroy_messages_forum
    debug "  * Destruction des messages forum"
    db_forum = SQL3::Database::new('./database/data/forum.db')

    request = "SELECT id FROM posts WHERE user_id = #{user.id};"
    messages_id = db_forum.execute(request).collect do |arr_with_id|
      arr_with_id[0]
    end

    request = <<-SQL
UPDATE posts_content
  SET content = "[Contenu supprimé : utilisateur supprimé]"
  WHERE id IN (#{messages_id.join(',')});
    SQL
    db_forum.execute( request )
    debug "  = Messages initialisés"

    request = "DELETE FROM sujets_followers WHERE user_id = #{user.id}"
    db_forum.execute( request )
    debug "  = Suppression de ses suivis"

    request = <<-SQL
SELECT id, items_ids FROM sujets_followers
  WHERE (items_ids LIKE ',#{user.id} ,') OR ( items_ids LIKE '[#{user.id},') OR ( items_ids LIKE '#{user_id}]');
    SQL
    db_forum.execute( request ).each do |row|
      sid, items_ids = row
      items_ids = eval(items_ids)
      items_ids.delete(user.id)
      items_ids = items_ids.inspect
      req = "UPDATE sujets_followers SET items_ids = #{items_ids} WHERE id = #{sid};"
      db_forum.execute(request)
    end
    debug "  = Suppresion des listes de sujets suivis"

    debug "  = Messages forum détruits"
  end

  # Destruction des programmes UN AN UN SCRIPT
  def destroy_programmes_unan
    debug "  * Destruction des programmes & projets UN AN UN SCRIPT"
    # On charge tout ce qui concerne Unan, on en aura
    # besoin plus bas (pour les bases de données)
    site.require_objet 'unan'
    # Destruction des paiements "1UN1SCRIPT" de l'user
    where = "(user_id = #{user.id}) AND (objet_id = '1AN1SCRIPT')"
    nombre_paiements = User::table_paiements.count(where:where)
    User::table_paiements.delete(where:where)

    # Destruction de son dossier dans database/data/unan/user
    with_dossier_db = user.folder_data.exist? ? "détruit" : "inexistant"
    user.folder_data.remove if user.folder_data.exist?

    # Destruction de ses programmes dans la table
    where = "auteur_id = #{user.id}"
    nombre_programmes = Unan::table_programs.count(where:where)
    nombre_projets    = Unan::table_projets.count(where:where)
    Unan::table_programs.delete(where:where)
    # Destruction de ses projets dans la table
    Unan::table_projets.delete(where:where)

    debug "  = Destruction des programmes UAUS OK"
  end


  # ---------------------------------------------------------------------
  #   Helper méthodes
  # ---------------------------------------------------------------------

  def self.menu_raison_supp_compte
    RAISONS_DESTROY.each_with_index.collect do |raison, iraison|
      raison.in_option(value: iraison)
    end.join('').in_select(name:'destroy[raison]', id:'destroy_raison')
  end
end

if param(:operation) == 'destroy_compte'
  user.exec_destroy
end
