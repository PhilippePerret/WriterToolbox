# encoding: UTF-8
=begin

  Définition du schéma de la table qui contient les résultats des
  questionnaires/quiz

  Si c'est un user connu (identified?), on l'enregistre avec sa réponse.

=end
def schema_table_resultats
  <<-MYSQL
CREATE TABLE resultats
  (
    id INTEGER AUTO_INCREMENT,

    # USER_ID
    # -------
    # User, si identifié, qui a rempli ce questionnaire
    user_id INTEGER,

    # REPONSES
    # --------
    # Réponses du visiteur, c'est un hash en string contenant
    # les réponses (format JSON).
    reponses BLOB NOT NULL,

    # POINTS
    # ------
    # Nombre de points marqué pour ce questionnaire, pour éviter
    # d'avoir à les recalculer.
    points INTEGER(4) NOT NULL,

    # CREATED_AT
    # ----------
    # Timestamp de la création du projet
    created_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
