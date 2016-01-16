# encoding: UTF-8
class Unan
class Program


  # Démarre le jour-programme suivant
  def start_next_pday
    start_pday( current_pday(:nombre) + 1 )
  end

  # Démarre le jour-programme d'index +ipd+ du programme courant
  #
  # NOTE
  # Cette méthode peut être appelée à n'importe quelle heure par
  # le cron-job pour faire passer au jour suivant, car la méthode
  # `test_if_next_pday` ci-dessus est appelée toutes les heures
  # par le CRON job.
  # NOTE
  # Tous les p-days n'ont pas forcément de travail, donc un
  # changement de p-day peut se résumer à son changement d'index
  # dans le programme courant.
  def start_pday ipday

    # Instancier un PDay pour le PDay absolu
    pday = PDay::new(self, ipday)

    # Listes qui permettent de dispatcher les différents types
    # de travaux. Permet notamment de gérer les onglets du bureau
    # Ces listes seront enregistrées dans des variables de l'auteur,
    # en ajoutant `_ids` à la fin des clés utilisées ci-dessous.
    ids_lists = {
      pages:  Array::new(),
      quiz:   Array::new(),
      tasks:  Array::new(),
      forum:  Array::new(),
      none:   Array::new()
    }


    abs_pday.works.each do |work|
      # Les données de type de travail
      list_id = Unan::Program::AbsWork::TYPES[work.type_w][:id_list]
      # On ajoute ce travail dans la liste adéquate
      ids_lists[list_id] << work.id
    end

    # Enregistrement des listes d'ids dans les variables de
    # l'auteur.
    # Noter qu'il y a de fortes chances pour que les variables
    # contiennent déjà des valeurs, donc il faut bien ajouter
    # aux listes et non pas ré-initialiser, ce qui perdrait les
    # travaux précédents.
    # TODO
    ids_lists.each do |key_list, ids_list|
      next if ids_list.empty?
      key = "#{key_list}_ids".to_sym.freeze
      list = auteur.get_var(key, Array::new)
      list += ids_list
      auteur.set_var( key, list)
    end

    # On enregistre le jour-programme suivant dans la variable
    # `current_pday` de l'auteur
    auteur.set_var :current_pday => ipday.freeze

    if auteur.daily_summary?
      # TODO Il faut avertir l'auteur s'il y a un nouveau travail,
      # sinon le prévenir aussi avec un récapitulatif si ses
      # préférences le nécessitent.

    end

  end

end #/Program
end #/Unan
