# encoding: UTF-8
=begin

  show_table <{BdD::Table} table>

  La méthode `show_table` se trouve dans le fichier
    ./lib/deep/deeper/optional/_per_route/site/console/table.rb

=end
raise_unless_admin

class SiteHtml
class Admin
class Console



  def affiche_table_of_database last_word
    sub_log "Affichage de la table : #{last_word}"
    path, table = last_word.split('.')
    raise "Il faut définir le nom de la table dans la requête." if table.nil?
    full_path = SuperFile::new("./database/data/#{path}.db")
    raise "La base de données `#{full_path}` n'existe pas…" unless full_path.exist?
    bdd = BdD::new(full_path.to_s)
    tbl = ( bdd.table table )
    raise "La table `#{table}` n'existe pas dans la base de données spécifiée (dont l'existence a été vérifiée)" unless bdd.table(table).exist?
    show_table tbl
  rescue Exception => e
    sub_log "`#{last_word}` est invalide.\n" +
      "Expected : path/to/db/depuis/database/data/sans/db DOT nom_table\n"+
      "Example  : `affiche table forum.posts`\n" +
      "Pour     : la table `posts` dans la db `./database/data/forum.db`.\n" +
      "Example  : `affiche table unan/user/2/programme1.pdays`\n" +
      "Pour     : la table `pdays` dans la db `./database/data/unan/user/2/programme1.db`"

    "# ERROR: #{e.message}"
  else
    "OK"
  end
end #/Console
end #/Admin
end #/SiteHtml

=begin
=end
