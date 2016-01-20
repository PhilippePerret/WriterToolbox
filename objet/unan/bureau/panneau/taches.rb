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
class Unan
class Bureau

  def save_travail
    flash "Je sauve les données travail"

    # TODO Sauver la nouvelle liste de travaux
    # set_var(:travaux_ids, travaux_ids)

  end

  # cf. l'explication dans le fichier home.rb
  def missing_data
    @missing_data ||= begin
      nil # pour le moment
      # Une alerte si des travaux devraient être accomplis et qu'ils
      # ne le sont pas.
    end
  end

  # {Array} Liste des instances Unan::Program::Travaux courantes
  # de l'user, pour boucler dessus et les afficher, ou autre
  # travail.
  def works
    @works ||= works_ids.collect { |wid| Unan::Program::Work::new(user.program, wid) }
  end

  # {Array} Liste ordonnée des IDs de travaux à accomplir par
  # l'auteur
  def works_ids
    @works_ids ||= user.get_var(:works_ids, Array::new)
  end

  def table_travaux
    @table_travaux ||= User::table_works
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
  def output
    "[LE TRAVAIL - INTITULÉ ET DESCRIPTION]" +
    "[FORMULAIRE POUR L'ENREGISTRER, LE MARQUER FINI, CONFIRMER LE DÉMARRAGE]"+
    form
  end
  def form
    "[Formulaire]"
  end



end #/Work
end #/Program
end # /Unan


case param :operation
when 'bureau_save_travail'
  bureau.save_travail
end
