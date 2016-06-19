# encoding: UTF-8
def schema_table_tdms
  <<-MYSQL
CREATE TABLE tdms
  (
    id INTEGER AUTO_INCREMENT,

    #  TDM
    # -----
    # Liste string des identifiants des pages, des
    # chapitres ou des sous-chapitres (dans la table
    # narration) séparés par des espaces.
    tdm   BLOB  NOT NULL,

    updated_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
