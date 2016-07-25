# encoding: UTF-8
=begin

  Table permettant d'enregistrer les users autorisés

=end
def schema_table_autorisations
  <<-MYSQL
CREATE TABLE autorisations
  (
    #  ID
    # ----
    # Identifiant de l'autorisation, PAS de l'user (cf. ci-dessous)
    #
    id INTEGER AUTO_INCREMENT,

    # USER_ID
    # -------
    # Identifiant de l'user ayant l'autorisation
    #
    user_id     INTEGER,

    # START_TIME
    # -----------
    # Time de début d'autorisation. Permettra de la régler
    # aussi dans le futur.
    # Noter que la valeur peut être nil, si l'user peut déclencher
    # son abonnement quand il le désire
    start_time INTEGER(10),

    #  END_TIME
    # ----------
    # Time de fin d'autorisation.
    # Peut être nil, soit lorsque l'autorisation est éternelle ou
    # non fixée, ou lorsque l'abonnement n'est pas encore commencé
    end_time INTEGER(10),

    # NOMBRE_JOURS
    # ------------
    # Nombre de jours d'abonnements, utile quand start_time
    # est nil, pour connaitre le nombre de jours d'abonnement
    nombre_jours INTEGER(4),

    # PRIVILEGES
    # ----------
    # Le niveau de privilège de l'user, qui n'est pas encore
    # vraiment utilisé
    privileges INTEGER(1),

    # RAISON
    # ------
    # La raison pour laquelle des jours ont été accordés
    # Par exemple, lorsque l'user a obtenu la meilleure note
    # à un quiz, au-dessus de 15, la raison est "QUIZ <suffixe-base> <quiz-id>"
    # pour ne pas lui attribuer deux fois des jours.
    raison TEXT,

    created_at  INTEGER(10),
    updated_at  INTEGER(10),

    PRIMARY KEY (id),
    INDEX idx_user  (user_id)

  );
  MYSQL
end
