# encoding: UTF-8
class Unan
class Program

  # = main =
  #
  # Fonction principale appelée par le CRON job pour savoir
  # s'il faut passer le programme (l'auteur) au jour-programme
  # suivant, en fonction de son rythme et de son jour-programme
  # courant.
  # NOTE : Cette méthode est appelée TOUTES LES HEUREUS. Donc
  # il faut vérifier s'il faut réellement passer au jour-programme
  # suivant. Note : Le CRON fonctionne toutes les heures pour pouvoir
  # suivre les rythmes exacts programmés. Noter que ça a aussi
  # l'avantage d'envoyer les mails au bon moment.
  def test_if_next_pday
    return if NOW < next_pday_time
    start_next_pday
  end

  # Durée d'un jour-programme en fonction du rythme choisi
  # par l'auteur.
  def pday_duration
    @pday_duration ||= Fixnum::DUREE_JOUR * coefficient_pday
  end

  # Coefficient de durée du jour-programme
  # @usage : On MULTIPLIE la durée réelle par ce nombre pour
  # obtenir la durée-programme.
  def coefficient_pday
    @coef_pday ||= 5.0 / rythme
  end


  # Timestamp du jours suivant
  def next_pday_time
    @next_pday_time ||= last_pday_time + pday_duration
  end
  # Timestamp du jour-programme courant, donc du dernier
  # jour-programme du programme courant. Si aucun pday
  # n'est encore défini, on retourne la date de démarrage
  # du programme courant. Mais normalement, un pday a été
  # créé au démarrage du programme (cf. signup_user.rb)
  def last_pday_time
    @last_pday_time ||= ( icurrent_pday.nil? ? self.created_at : icurrent_pday.start )
  end

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

  # Retourne le jour-programme courant, mais au format
  # d'instance Unan::Program::PDay
  # C'est un raccourci pour `current_pday(:instance)`
  def icurrent_pday
    @icurrent_pday ||= current_pday(:instance)
  end

  # {Any} Retourne le jour programme courant au format +as+
  #   :human      Sous la forme "2e jours"
  #   :nombre     Sous la forme `2`
  #   :instance   Instance Unan::Program::PDay
  #
  # NOTE : C'est c'est l'instance qui est demandée et que le
  # jour-programme courant n'est pas défini (premier), la méthode
  # retourne NIL. Dans les autres formats, elle retourne 1 ou
  # "1er jour".
  # NOTE : C'est une `variable` de l'auteur de name :current_pday
  def current_pday as = :nombre # ou :human
    @ijour_actif ||= auteur.get_var(:current_pday, :none)
    # En fonction du type du retour
    case as
    when :instance
      @ijour_actif == :none ? nil : PDay::new(self, @ijour_actif)
    when :human, :humain
      @ijour_actif = 1 if @ijour_actif == :none
      mark = @ijour_actif == 1 ? "er" : "e"
      "#{@ijour_actif}<sup>#{mark}</sup> jour"
    when :nombre, :number
      @ijour_actif == :none ? 1 : @ijour_actif
    else
      @ijour_actif
    end
  end

end #/Program
end #/Unan
