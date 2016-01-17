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

    # Instancier un AbsPDay pour ce jour
    # (est-ce vraiment utile ?)
    abs_pday = AbsPDay::new(ipday)

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

    abs_pday.works(:as_instance).each do |work|
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

    # On enregistre le P-Day dans la base de donnée du
    # programme de l'auteur
    pday.save

    # On enregistre le jour-programme suivant dans la variable
    # `current_pday` de l'auteur
    # Noter que ce nombre, qui correspond à l'index du jour-programme,
    # donc un nombre de 1 à 365, est équivalent à l'ID du pday
    # ci-dessus, qu'on peut donc charger avec cet ID justement.
    auteur.set_var :current_pday    => ipday.freeze

    if auteur.daily_summary?
      # TODO Il faut avertir l'auteur s'il y a un nouveau travail,
      # sinon le prévenir aussi avec un récapitulatif si ses
      # préférences le nécessitent.
      # Il y a trois cas différents à traiter :
      #   1. L'auteur ne veut être averti que des changements de
      #      travaux. Donc il ne faut lui envoyer un mail que lorsque
      #      le p-day change ET qu'un nouveau travail est demandé.
      #   2. L'auteur veut être averti tous les jours, il veut recevoir
      #      un mail récapitulatif tous les jours. Donc que le jour-programme
      #      change ou ne change pas, qu'il y a ait ou non du travail ou
      #      qu'il n'y en ait pas, on lui envoie un mail.
      #   3.
      #
      #  CAS
      # -----
      # * Le jour-programme change mais sans nouveau travail
      #   Auteur voulant être informé tous les jours
      #   ->  Annonce du changement de jour-programme
      #   ->  Rappel de ses travaux courants. Un message adapté suivant le nombre
      #       de jours depuis le début du travail.
      #   Auteur ne voulant pas être informé tous les jours
      #   -> Rien
      # * Le jour-programme change mais avec de nouveaux travaux
      #   Auteur voulant être informé tous les jours
      #   ->  Annonce du changement de jour-programme
      #   ->  Annonce des nouveau travaux
      #   ->  Rappel de ses travaux courants
      #   Auteur ne voulant pas être informé tous les jours
      #   ->  Information sur le nouveau jour-programme
      #   ->  Annonce des nouveaux travaux
    end

  end

end #/Program
end #/Unan
