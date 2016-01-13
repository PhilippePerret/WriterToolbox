# encoding: UTF-8
=begin
Extension de User propre au programme
=end
class User

  # {Unan::Program} Le programme courant (ou nil)
  def program
    @program ||= Unan::Program::get_current_program_of(self.id)
  end
  # ID du programme de l'user
  # Noter que ça ne fonctionne comme habituellement : ici, la
  # propriété ne permettra pas de définir l'instance, c'est au
  # contraire l'instance (program ci-dessus) qui permet de
  # définir la propriété.
  # Ça a été fait comme ça pour faciliter le travail à la
  # création de l'inscription, qui définit @program_id qui
  # servira aussi pour les tables personnelles à construire sans
  # que le programme doive être chargé.
  def program_id; @program_id ||= program.id end

  # Données de la table `variables`
  def travaux_ids=        arr_ids; set_var :travaux => arr_ids end
  def travaux_ids         ; @travaux_ids ||= get_var(:travaux) end
  def messages_forum_ids= arr_ids; set_var :messages_forum => arr_ids end
  def messages_formum_ids ; @mess_forum_ids ||= get_var(:messages_forum) end
  def quiz_ids=           arr_ids; set_var :quiz => arr_ids           end
  def quiz_ids            ; @quiz_ids ||= get_var( :quiz )            end
  def pages_cours_ids=    arr_ids; set_var :pages_cours => arr_ids    end
  def pages_cours_ids     ; @pages_cours_ids ||= get_var(:pages_cours)end
end
