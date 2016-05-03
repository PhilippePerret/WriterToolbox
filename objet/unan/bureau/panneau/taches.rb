# encoding: UTF-8
=begin
Extension de la class Unan::Bureau pour afficher le travail en
cours de l'auteur.

Noter que ce module est le seul module "optionnel" appelé quand
l'auteur rejoint son panneau "travaux" donc ça n'est pas grave
s'il est conséquent.

Ce travail doit être contenu sous forme de liste dans la variable
`travaux_ids` qui est renseignée à mesure que l'auteur avance dans
les jours et qu'il exécute des travaux.
=end
Unan::require_module 'abs_work'

class Unan
class Bureau

  def save_travail
    flash "Je sauve les données travail"
  end

  # cf. l'explication dans le fichier home.rb
  def missing_data
    @missing_data ||= begin
      nil # pour le moment
      # Une alerte si des travaux devraient être accomplis et qu'ils
      # ne le sont pas.
    end
  end

  def tasks
    @tasks ||= begin
      works # pour le moment, tous les travaux
      # works_ids.collect{ |wid| Unan::Program::Work::get(user.program, wid) }
    end
  end
  # Raccourci
  def last_tasks
    []
    # @last_tasks ||= user.program.last_tasks
  end

end # /Bureau

# ---------------------------------------------------------------------
#   Extention de Unan::Program::Work
#   Pour l'affichage des travaux
# ---------------------------------------------------------------------
class Program
class Work
  # {StringHTML} Retourne le code HTML à écrire dans la page pour
  # ce travail en particulier.
  # Noter que c'est une méthode de `Work` plutôt que de `AbsWork` pour
  # s'adapter exactement à l'auteur en particulier.
  # Noter qu'elle sert aussi pour les travaux qui viennent d'être
  # achevés (mis en bas de page) et que donc, certaines informations
  # comme les dates, ne sont pas toujours affichées.
  def output
    Unan::require_module 'work'
    self.as_card
  end
end #/Work
end #/Program
end # /Unan


case param :operation
when 'bureau_save_travail'
  bureau.save_travail
end
