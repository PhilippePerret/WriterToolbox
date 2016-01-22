# encoding: UTF-8
=begin

Class Unan::Program::StarterPDay
--------------------------------
Méthode prepare_proper_pday qui prépare le jour-programme et donc
ses travaux.
=end
class Unan
class Program
class StarterPDay

  # Quand le jour-programme courant existe, c'est-à-dire
  # possède des travaux, il faut créer un P-Day propre pour
  # le programme courant, qui va permettre de consigner les
  # informations sur ce jour-programme.
  # Il faut aussi créer des "work" pour chaque "absolute work"
  # qui est défini par le jour-programme.
  def prepare_program_pday

    # Listes qui permettent de dispatcher les différents types
    # de travaux. Permet notamment de gérer les onglets du bureau
    # Ces listes seront enregistrées dans des variables de l'auteur,
    # en ajoutant `_ids` à la fin des clés utilisées ci-dessous.
    # Par exemple, la liste des questionnaires se trouvera dans
    # `quiz_ids` tandis que la liste des pages de cours à lire se
    # trouvera dans `pages_ids`.
    ids_lists = {
      works:  Array::new(), # contient tous les travaux
      pages:  Array::new(),
      quiz:   Array::new(),
      tasks:  Array::new(),
      forum:  Array::new(),
      none:   Array::new()  # ?
    }

    abs_pday.works(:as_instance).each do |abswork|

      # Il faut commencer par créer une instance Unan::Program::Work
      # propre pour ce travail
      work = Unan::Program::Work::new(program, id = nil)
      work.data2save= {
        program_id:   program.id,
        abs_work_id:  abswork.id,
        status:       "0",
        options:      "",
        created_at:   NOW,
        updated_at:   NOW
      }
      work.create

      # Les données de type de travail
      list_id = Unan::Program::AbsWork::TYPES[abswork.type_w][:id_list]

      # TODO Voir si le travail peut être accompli. Si sa donnée
      # prev_work est définie et que le travail précédent n'est pas
      # marqué fini, il faut l'indiquer. Au bout d'un certain temps,
      # il faut faire quelque chose.

      # On ajoute ce travail dans la liste adéquate
      ids_lists[list_id]  << work.id
      # On ajoute toujours le travail dans la liste de tous
      # les travaux
      ids_lists[:works]   << work.id

      # Le titre du nouveau travail doit être ajouté au mail
      mail_auteur.nouveaux_travaux << abswork.titre.in_li

    end

    # Enregistrement des listes d'ids dans les variables de
    # l'auteur.
    # Noter qu'il y a de fortes chances pour que les variables
    # contiennent déjà des valeurs, donc il faut bien ajouter
    # aux listes et non pas ré-initialiser, ce qui perdrait les
    # travaux précédents.
    ids_lists.each do |key_list, ids_list|
      next if ids_list.empty?
      key = "#{key_list}_ids".to_sym.freeze
      list = auteur.get_var(key, Array::new)
      list += ids_list
      auteur.set_var( key, list)
    end

    # On enregistre le P-Day dans la base de donnée du
    # programme de l'auteur
    pday.create

  rescue Exception => e
    log "#ERREUR FATALE : #{e.message}"
    log "#MALHEUREUSEMENT, IL EST IMPOSSIBLE DE DÉTERMINER LA LISTE DES NOUVEAUX TRAVAUX…"
  else
    true # pour poursuivre
  end
end #/StarterPDay
end #/Program
end #/Unan
