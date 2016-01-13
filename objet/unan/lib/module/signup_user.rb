# encoding: UTF-8
class User

  def signup_program_uaus

    (folder_modules + 'signup').require
    # Création du programme (dans la table générale des programmes)
    @program_id = Unan::Program::create
    # Création du projet (dans la table générale des projets)
    @projet_id  = Unan::Projet::create
    # Création des tables du programme
    create_tables_1a1s
    # pour les tests
    return program_id
  end

end
