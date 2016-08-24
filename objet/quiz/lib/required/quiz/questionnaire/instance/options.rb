# encoding: UTF-8
=begin

  Méthodes pour les options du quiz

=end
class Quiz

  # Pour régler les options de l'extérieur
  # @usage :
  #   quiz.no_pre_description = true
  attr_accessor :no_pre_description
  attr_accessor :no_post_description
  # Pour ne pas afficher le message qui donne le résultat par rapport aux
  # autres tests effectués par d'autres personnes, et permet de gagner des
  # jours d'abonnement gratuits.
  attr_accessor :no_message_note_finale

  # Valeurs des bits d'options
  OPTIONS = {
    0 => {hname: 'courant', description: '1: quiz courant, 0: pas courant'},
    1 => {hname: 'aléatoire', description: '1: questions dans un ordre aléatoire, 0: questions dans ordre prédéfini'},
    2 => {hname: 'Centaine du nombre max de questions ou -', description: nil},
    3 => {hname: 'Dizaine du nombre max de questions ou -', description: nil},
    4 => {hname: 'Unité du nombre max de questions ou 0', description: nil},
    5 => {hname: 'Hors de liste', description: '1: hors des listes — par exemple les quiz de test ou du programme UNAN'},
    6 => {hname: 'Réutilisable', description: 'Pour le programme UNAN, un test réutilisable permet d’être fait autant de fois qu’on veut, mais ne génère pas de point.'}
  }

  def pre_description?
    !self.no_pre_description
  end
  def post_description?
    !self.no_post_description
  end
  def message_note_finale?
    !self.no_message_note_finale
  end

  # Les options par défaut. Obligatoire pour gérer l'édition
  # correcte d'un nouveau quiz.
  def default_options
    @default_options ||= "00--000"
  end

  # 1er bit des options, pour savoir si le quiz est le quiz courant
  #
  def current?
    options[0].to_i == 1
  end

  # 2e bit des optionis
  def random?
    options[1].to_i == 1
  end
  alias :aleatoire? :random?


  # Bits 3 à 5 des options ('-' mis pour '0')
  #
  # NIL s'il n'y a pas de nombre max.
  # Note : On pourrait aussi dire que c'est le nombre de questions.
  def nombre_max_questions
    @nombre_max_questions ||= begin
      m = options[2..4].gsub(/\-/,'').to_i
      m > 0 ? m : nil
    end
  end

  # Noter que pour le moment il faut le régler manuellement
  def hors_liste?
    options[5].to_i == 1
  end

  # 7e bit des options
  def reusable?
    options[6].to_i
  end

end #/Quiz
