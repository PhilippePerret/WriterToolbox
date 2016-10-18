# encoding: UTF-8
def schema_table_narration
  <<-MYSQL
CREATE TABLE narration
  (
    id          INTEGER     AUTO_INCREMENT,
    livre_id    INTEGER(2),
    created_at  INTEGER(10) NOT NULL,
    updated_at  INTEGER(10) NOT NULL,

    # HANDLER
    # -------
    # Nom du fichier dans le dossier. S'il s'agit d'un
    # chapitre ou d'un sous-chapitre, cette valeur est
    # nulle.
    handler VARCHAR(200),

    # TITRE
    # Titre de la page qui sera utilisé notamment les
    # tables des matières et la page
    titre VARCHAR(255) NOT NULL,

    # DESCRIPTION
    # -----------
    # Un description optionnelle du contenu du fichier
    description TEXT,

    # OPTIONS
    # -------
    # Cf. ./objet/cnarration/lib/required/page/options.rb
    options VARCHAR(32),

    PRIMARY KEY (id)
  );
  MYSQL
end
