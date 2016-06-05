# encoding: UTF-8
=begin

  Module qui doit gérer les connexions au site, pour les mémoriser
  et empêcher les intrusions intempestives.

  Le principe est de travailler avec des bases de données, plusieurs,
  qui permettent de prendre en compte les connexions par leur IP

=end
class SiteHtml

  # = main =
  #
  # Méthode principale qui AJOUTE UNE CONNEXION AU SITE
  #
  # Fonctionnement : La méthode tente d'ajouter l'adresse
  # IP à la première base. Si la base n'existe pas, elle
  # la crée. Si la base est occupée, elle ajoute l'adresse
  # dans la deuxième base ou la troisième et les crée si
  # nécessaire.
  def add_connexion ip
    # Ne pas enregistrer le cron job qui se connecte au site
    return if defined?(CRONJOB) && CRONJOB
    # Ne pas enregistrer les commandes SSH qui viennent de
    # l'administration (pour les tests online)
    ip != '87.98.168.93' || return
    # Dans tous les autres cas, on enregistre la connexion
    (1..10).each do |ibase|
      pbase = folder_connexions_by_ip + "connexions#{ibase}.db"
      unless pbase.exist?
        dbase = SQLite3::Database::new(pbase.to_s)
        create_base_connexion( dbase )
      end
      dbase ||= SQLite3::Database::new(pbase.to_s)
      begin
        dbase.execute( code_insert_connexion ip )
      rescue Exception => e
        debug e
      else
        break # on peut finir si on a pu enregistrer
      ensure
        (dbase.close if dbase) rescue nil
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def code_insert_connexion ip
    # debug "self.route: #{self.route.to_str}"
    <<-SQL
INSERT INTO connexions
  (ip, time, route)
  VALUES ('#{ip}', #{NOW}, "#{self.route.to_str}");
    SQL
  end

  # Création de la table des connexions dans la base
  def create_base_connexion dbase
    dbase.execute(code_creation_base_connexion)
  end

  def code_creation_base_connexion
    <<-SQL
CREATE TABLE connexions(
  ip     TEXT  NOT NULL,
  time   INT   NOT NULL,
  route  TEXT  NOT NULL
);
    SQL
  end

  def folder_connexions_by_ip
    @folder_connexions_by_ip ||= begin
      d = site.folder_tmp + 'connexions'
      d.build unless d.exist?
      d
    end
  end
end #/SiteHtml
