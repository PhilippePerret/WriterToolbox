# encoding: UTF-8
class Unan
class Program

  # Méthode qui checke si les travaux courants de l'user ont
  # bien été démarrés. Ils doivent avoir le status > 0 (en tout
  # cas pour les tasks)
  # Pour les pages de cours, elles doivent avoir été marquées
  # vues (pas lues)
  def test_if_works_not_started
    Unan::require_module 'page_cours'
    deux_jours_avant = NOW - 2.days
    current_works(as: :instances).each do |iwork|
      nombre_jours = (NOW - iwork.created_at) / 1.days
      # Si le travail est donné depuis moins de deux jours,
      # il ne faut pas le checker
      next if iwork.created_at > deux_jours_avant
      # Sinon, il faut voir s'il a été démarré (pour une tâche)
      # ou marqué vue (pour une page de cours)
      if iwork.page_cours?
        # => Elle doit avoir été marquée "vu"
        ipage = User::UPage::get(auteur, iwork.item_id)
        next if ipage.vue? # OK
        error_message_page_not_vue(ipage, nombre_jours)
      elsif iwork.task?
        next if iwork.started? # OK
        error_message_work_not_started(iwork, nombre_jours)
      end
    end # / fin de boucle sur tous les travaux
  end

  def error_message_page_not_vue ipage, nombre_jours
    spec_page = "page “#{ipage.page_cours.titre}” (##{ipage.id})"
    alerte = case true
    when nombre_jours < 2
      "La #{spec_page} aurait dû être marquée vue depuis environ deux jours."
    when nombre_jours < 4
      "La #{spec_page} aurait dû être marquée vue depuis près de 4 jours maintenant…"
    when nombre_jours < 8
      "Il y a plus d'une semaine que la #{spec_page} aurait dû être marquée vue. Nous espérons que vous ne l'avez pas oubliée…"
    when nombre_jours < 32
      # => Fin du programme
      "Il y a près d'un moins que la #{spec_page} aurait dû être marqué vue. Nous devons vous considérer comme démissionnaire du programme. C'est vraiment dommage."
    end
    auteur.add_alerte_mail alerte
  end

  def error_message_work_not_started iwork, nombre_jours
    spec_work = "travail “#{iwork.titre}” (##{iwork.id})"
    alerte = case true
    when nombre_jours < 2
      "Le #{spec_work} aurait dû être marqué démarré."
    when nombre_jours < 4
      "Le #{spec_work} aurait dû être marqué démarré depuis bientôt 4 jours maintenant…"
    when nombre_jours < 8
      "Il y a plus d'une semaine que le #{spec_work} aurait dû être démarré "
    when nombre_jours < 32
      "Il y a près d'un moins que le #{spec_work} aurait dû être démarré. Malheureusement, je dois vous compter comme démissionnaire…"
    end
    auteur.add_alerte_mail alerte
  end

  # On teste si des messages reprogrammés sont trouvés dans les
  # deux heures suivantes et on les réinjecte dans le flux de
  # travail courant si c'est le cas.
  def check_if_ulteriors_works
    dans_deux_heures = NOW + ( 2 * 3600 )
    works_ids = self.table_works.select(where:"created_at > #{NOW} AND created_at < #{dans_deux_heures}", colonnes:[]).keys
    return if works_ids.empty?
    log "--- Des travaux reprogrammés sont à réinjecter dans le flux de travail de #{auteur.pseudo} (##{auteur.id}) : #{works_ids.inspect}"
    lists_ids = {
      works_ids: auteur.get_var(:works_ids),
      tasks_ids: auteur.get_var(:tasks_ids),
      pages_ids: auteur.get_var(:pages_ids),
      forum_ids: auteur.get_var(:forum_ids),
      quiz_ids:  auteur.get_var(:quiz_ids),
      works_ids_nombre_init: nil,
      tasks_ids_nombre_init: nil,
      pages_ids_nombre_init: nil,
      forum_ids_nombre_init: nil,
      quiz_ids_nombre_init: nil
    }
    # On prend le nombre initial de travaux de chaque type pour voir ceux
    # qu'il faudra ré-enregistrer (ceux modifiés)
    [:works_ids, :tasks_ids, :pages_ids, :quiz_ids, :forum_ids].each do |key|
      lists_ids["#{key}_nombre_init".to_sym] = (lists_ids[key]||Array::new).count.freeze
    end

    # On ajoute les travaux aux listes
    works_ids.each do |wid|

      iwork = Work::new(self, wid)
      # On ajoute toujours le travail à la liste des travaux
      lists_ids[:works_ids] << wid
      # Ensuite, on regarde le type du travail pour savoir
      # dans quelle liste l'ajouter aussi.
      case true
      when iwork.abs_work.page_cours? then lists_ids[:pages] << wid
      when iwork.abs_work.quiz?       then lists_ids[:quiz] << wid
      when iwork.abs_work.forum?      then lists_ids[:forum] << wid
      else lists_ids[:tasks_ids] << wid
      end

      # Il faut également modifier la date de création du travail
      # juste pour qu'il ne soit pas traité deux fois au prochain
      # check dans une heure.
      iwork.set(created_at: NOW)

    end #/Fin de boucle sur tous les travaux reprogrammés

    # On enregistre les listes, mais seulement celles qui ont été
    # modifiées
    [:works_ids, :tasks_ids, :pages_ids, :quiz_ids, :forum_ids].each do |key|
      if lists_ids["#{key}_nombre_init".to_sym] < (lists_ids[key]||Array::new).count
        auteur.set_var( key => lists_ids[key] )
        log " == Liste #{key} actualisée"
      end
    end

  end

end #/Program
end #/Unan
