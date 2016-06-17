# encoding: UTF-8
=begin

Définition de la table `pdays` qui définit précisément le travail (les
travaux) à accomplir pour chaque jour du programme Un An Un Script.
Donc il y a 365 pdays définis dans cette table.
=end
def schema_table_absolute_pdays
  <<-MYSQL
CREATE TABLE absolute_pdays
  (
    # ID
    # --
    # Index exact du P-Day, le jour-programme
    # Contrairement aux autres tables, cette données doit être affectée
    # explicitement pour correspondre à un des 368 p-days du programme.
    # Note : Correspond à `index` des instances Unan::Program::PDay.
    # Note : 1-start
    id INTEGER(3) NOT NULL,

    # TITRE
    # -----
    # Le titre qui donne la "couleur" du travail du jour-programme
    titre VARCHAR(255),

    # DESCRIPTION
    # -----------
    description TEXT,

    # WORKS
    # -----
    # La liste (ordonnée) de tous les travaux à accomplir au cours de
    # ce jour-programme.
    #
    # C'est une liste string où les identifiants des travaux sont
    # séparés par des simples espaces.
    works VARCHAR(255),

    # MINIMUM_POINTS
    # --------------
    # Pour le moment, cette valeur ne sert à rien mais à l'avenir,
    # elle pourrait définir le minimum de points qu'il faut pour
    # passer au jour-programme suivant.
    minimum_points INTEGER(3),

    # CREATED_AT
    # ----------
    # Timestamp de la création du projet
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Timestamp de la modification de cette donnée
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
