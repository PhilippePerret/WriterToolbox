# encoding: UTF-8
=begin

  Définition de la table `users` dans la table boite-a-outils_hot
  de la boite à outils de l'auteur

=end
def schema_table_users
  @schema_table_users ||= <<-MYSQL
CREATE TABLE users
  (
    /*
      On doit toujours mettre un identifiant qui est auto-incrémenté
      et est presque toujours un entier.
    */
    id int AUTO_INCREMENT,

    # PSEUDO
    # ------
    pseudo VARCHAR(40) NOT NULL,

    # PATRONYME
    # ---------
    # Un patronyme doit toujours être fourni
    # Mais il n'est pas encore utilisé maintenant
    patronyme VARCHAR(255) NOT NULL,

    # MAIL
    # ----
    mail VARCHAR(255) NOT NULL,

    # CPASSWORD
    # ---------
    # Mot de passe crypté.
    cpassword VARCHAR(32),

    # SALT
    # ----
    # Le sel qui permet de crypter le mot de passe
    salt VARCHAR(32),

    # SESSION_ID
    # ----------
    # Le numéro de session courant, pour voir si l'utilisateur
    # est toujours dans la même session ou non (comptage de pages
    # par exemple)
    session_id VARCHAR(32),

    # OPTIONS
    # -------
    # Les options de l'user.
    # 32 caractères (ou plus) pour spécifier l'user
    # Cf. le fichier ./lib/deep/deeper/required/User/instance/options.rb
    # ATTENTION : LES OPTIONS PEUVENT ÊTRE DÉFINIES :
    #   - de 0 à 15 pour restsite dans User/instance/options.rb
    #   - de 16 à 31 pour l'application :
    #     - dans ./objet/site/config.rb (user_options)
    #     - dans ./lib/app/required/user/options.rb
    options VARCHAR(32),

    # SEXE
    # ----
    # 'H' ou 'F' pour savoir si c'est un homme ou une femme
    sexe CHAR(1),

    # ADDRESS
    # -------
    # Adresse physique de l'user
    address TEXT,

    # TELEPHONE
    # ---------
    telephone VARCHAR(10),

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10),

    # CREATED_AT
    # ----------
    # Date de création de la donnée, donc d'inscription
    # de l'user
    created_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
