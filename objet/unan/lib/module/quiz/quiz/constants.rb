# encoding: UTF-8
class Unan
class Quiz

  # Liste des options qui vont constituer la valeur de
  # la propriété `options` enregistrée.
  # Chaque option doit renvoyer à une méthode <option>? qui
  # retourne true si la valeur du bit est 1.
  OPTIONS = {
    'description'       => {bit:0, hname:"Afficher la description"},
    'only_points_quiz'  => {bit:1, hname:"Les questions n'apportent aucun point"},
    'no_titre'          => {bit:2, hname:"Ne pas afficher le titre du questionnaire"}
  }

  # ---------------------------------------------------------------------
  #   Options
  #
  # Définir dynamiquement toutes les méthodes d'options
  # description?, no_titre? etc.
  # Cf. la constante OPTIONS définie dans
  # OPTIONS.each do |k, dk|
  #   define_method "#{k}?" do
  #     options[dk[:bit]].to_i == 1
  #   end
  # end
  def description?
    options[0].to_i == 1
  end
  def only_points_quiz?
    options[1].to_i == 1
  end
  def no_titre?
    if options.nil?
      return false
    else
      options[2].to_i == 1
    end
  end
end #/Quiz
end #/Unan
