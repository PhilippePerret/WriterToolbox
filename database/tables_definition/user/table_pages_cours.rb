# encoding: UTF-8
=begin

Définition de la table `pages_cours` qui définit la lecture des
pages de cours d'un auteur en particulier.
Cette table est enregistrée dans la base de données propre à chaque
auteur qui suit le programme, dans la base de données du programme.
=end
def schema_table_user_pages_cours
  @schema_table_user_pages_cours ||= {

    # Identifiant unique (mais seulement pour cette table propre
    # à l'auteur)
    # Correspond à l'IDentifiant de la page de cours absolue. Donc
    # il doit impérativement être fourni à la création de la donnée.
    # En sachant donc qu'une page de cours peut être lue plusieurs
    # fois
    id: {type:"INTEGER", constraint:"PRIMARY KEY"},

    #  Statut
    # --------
    # 0: La page n'est pas encore lue, mais elle doit l'être
    # 1: Première lecture de la page (mais elle continue de s'afficher
    #    sur le centre de travail de l'auteur)
    # 3: La page est enregistrée dans la table des matières personnelle
    #    de l'auteur. Elle apparait (titre)
    # 9: La page n'est plus à lire.
    status:   {type:"INTEGER(1)", constraint:"NOT NULL"},

    #  Lectures
    # ----------
    # Un Hash contenant les dates de lecture de la page concernée.
    lectures:  {type:"BLOB"},

    # Position dans la table des matières
    # Ou NIL si non défini
    index_tdm:  {type:"INTEGER(4)"},

    #  Note
    # ------
    # Un texte, commentaire personnel que l'auteur peut laisser sur la
    # page, par exemple pour se souvenir de ce qu'elle contient, pour
    # lui.
    comments: {type:"TEXT"},

    # ID du travail de l'auteur
    # --------------------------
    # ID du travail Unan::Program::Work
    # Noter deux choses importantes ici :
    #   * Une page pouvant servir à plusieurs lectures, donc à plusieurs
    #     travaux, ce work_id concerne toujours LE DERNIER.
    #   * Cet ID peut ne pas être défini, quand la page n'a pas encore été
    #     marquée "vue".
    # 
    work_id: {type:"INTEGER"},

    # Noter que cette date de création de la donnée ne correspond pas
    # à la date de lecture.
    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"},
    # Date de dernière modification
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
