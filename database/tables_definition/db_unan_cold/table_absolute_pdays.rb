# encoding: UTF-8
=begin

Définition de la table `pdays` qui définit précisément le travail (les
travaux) à accomplir pour chaque jour du programme Un An Un Script.
Donc il y a 365 pdays définis dans cette table.
=end
def schema_table_unan_cold_absolute_pdays
  @schema_table_unan_absolute_pdays ||= {

    # Identifiant/index du p-day
    # --------------------------
    # Contrairement aux autres tables, cette données doit être affectée
    # explicitement pour correspondre à un des 368 p-days du programme.
    # Note : Correspond à `index` des instances Unan::Program::PDay.
    # Note : 1-start
    id: {type:"INTEGER(3)", constraint:"PRIMARY KEY"},

    # Titre du p-day
    # --------------
    # En gros, ce titre doit donner la couleur, la tonalité, du travail
    # du jour.
    titre: {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # Description
    # ------------
    # Description générale du p-day. Par exemple, pour le premier jour,
    # il s'agit d'un accueil et d'une présentation générale du programme
    # et de ce que l'auteur va vivre en le suivant
    description: {type:"TEXT", constraint:"NOT NULL"},

    # Travaux
    # -------
    # La liste (ordonnée) de tous les travaux à accomplir au cours de
    # ce jour-programme
    works: {type:"BLOB", constraint:"NOT NULL"},

    # Nombre de points minimum
    # ------------------------
    # Le nombre minimum de points qui doivent être acquis pour considérer que
    # ce jour-programme est achevé et qu'on peut passer au suivant
    minimum_points: {type:"INTEGER(3)", constraint:"NOT NULL"}

  }
end
