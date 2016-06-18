# encoding: UTF-8
=begin
  Table pour les tweets permanent
  Cf. Manuel Divers > Twitter

=end
def schema_table_permanent_tweets
  <<-MYSQL
CREATE TABLE permanent_tweets
  (
    id INTEGER AUTO_INCREMENT,

    # MESSAGE
    # -------
    # Le message qui sera envoyé sur twitter
    message VARCHAR(150) NOT NULL,

    # BITLINK
    # -------
    # Un message contient toujours un lien conduisant à une
    # page du site (contenu directement dans le message)
    # On la place ici.
    bitlink VARCHAR(100),

    #  COUNT
    # -------
    # Le nombre de fois où le tweet a été envoyé
    count INTEGER(8),

    # LAST_SENT
    # ---------
    # Le timestamp de dernier envoi du tweet
    last_sent INTEGER(10),

    created_at INTEGER(10) NOT NULL,
    updated_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
