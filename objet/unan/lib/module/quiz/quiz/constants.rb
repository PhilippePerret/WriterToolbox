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

end #/Quiz
end #/Unan
