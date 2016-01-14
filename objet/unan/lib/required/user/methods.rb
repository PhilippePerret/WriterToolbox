# encoding: UTF-8
=begin
Extension des méthodes d'instance de User
=end
class User

  # Méthode appelée lorsque l'on détruit l'user par
  # User#remove. Noter que la méthode `remove` détruira l'user
  # de la table users.users.db, donc inutile de le faire ici.
  def app_remove
    # On détruit son dossier de données s'il existe
    folder_data.remove if folder_data.exist?
  end

end #/User
