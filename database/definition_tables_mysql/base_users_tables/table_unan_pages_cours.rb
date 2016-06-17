# encoding: UTF-8
=begin

Définition de la table `pages_cours` qui définit la lecture des
pages de cours d'un auteur en particulier.
Cette table est enregistrée dans la base de données propre à chaque
auteur qui suit le programme, dans la base de données du programme.
=end
def schema_table_unan_pages_cours(user_id)
  <<-MYSQL
CREATE TABLE unan_pages_cours_#{user_id}
  (
    # ID
    # --
    # Ce n'est pas un ID auto-incrémenté, c'est l'ID absolu
    # de la page de cours lue.
    id INTEGER,

    # STATUS
    # ------
    # 0 : page pas encore lue, mais doit l'être
    # 1 : Première lecture de la page
    # 3 : Page enregistrée dans la table des matières personnelle
    # 9 : Page qui n'est plus à lire
    status INTEGER(1) DEFAULT 0,

    # LECTURES
    # --------
    # Un hash (qui sera désérialisé) contenant les dates
    # de lecture de la page concernée.
    lectures BLOB,

    # INDEX_TDM
    # ---------
    # Position dans la table des matières personnelle
    index_tdm INTEGER(4),

    # COMMENTS
    # ---------
    # Un commentaire personnel que l'auteur peut faire sur
    # la page
    comments TEXT,

    # WORK_ID
    # -------
    # Id du travail de l'auteur associé à cette page de
    # cours à lire.
    # Notes
    #   * Une page pouvant servir à plusieurs lectures,
    #     donc à plusieurs travaux, c'est toujours le
    #     DERNIER TRAVAIL qui est consigné ici
    work_id INTEGER,

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10),

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  )
  MYSQL
end
