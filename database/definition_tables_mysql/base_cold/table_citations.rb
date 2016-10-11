# encoding: UTF-8
=begin
  Table pour les Citation

=end
def schema_table_citations
  <<-MYSQL
CREATE TABLE citations
  (
    id INTEGER AUTO_INCREMENT,
    citation    TEXT NOT NULL,
    auteur      VARCHAR(255)      NOT NULL,
    source      VARCHAR(255),
    description TEXT,

    #  BITLY
    # -------
    # Lien court (bit.ly) pour l'envoi par tweet. Cette URL
    # est automatiquement créée à la création de la citation
    bitly VARCHAR(50),

    # LAST_SENT
    # ---------
    # Timestamp du dernier envoi de la citation, pour savoir
    # quand on peut la réutiliser ou la réenvoyer sur tweeter
    last_sent INTEGER(10),

    created_at  INTEGER(10)       NOT NULL,
    updated_at  INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
