# encoding: UTF-8
class Unan
class Program

  # Instance {Unan::Program::CurPDay} du programme courant
  def cur_pday
    @current_pday ||= Unan::Program::CurPDay::new(current_pday, auteur)
  end

  # Méthode qui checke si les travaux courants de l'user ont
  # bien été démarrés. Ils doivent avoir le status > 0 (en tout
  # cas pour les tasks)
  # Pour les pages de cours, elles doivent avoir été marquées
  # vues (pas lues)
  def test_if_works_not_started
    return
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

end #/Program
end #/Unan
