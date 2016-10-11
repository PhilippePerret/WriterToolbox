# encoding: UTF-8
class User

  # Quand on détruit un user, propre à l'application
  def app_remove
    folder.exist? && folder.remove # Dossier des données et databases persos
  end
  
end
