# encoding: UTF-8
=begin

  Module “standalone” : il se trouve défini dans un objet mais
  il peut être appelé sans que l'objet lui-même ne soit appelé.

=end
class User

  # Méthode appelée par le header qui permet de mettre une pastille
  # indiquant le nombre de tâches que l'user doit accomplir dans
  # l'entête en haut à droite de la fenêtre.
  # Note : Cette pastille n'est pas à confondre avec celle des
  # administrateur. Celle-ci a été inaugurée pour le programme
  # UN AN UN SCRIPT
  # Noter que ce module est `standalone` c'est-à-dire que l'objet
  # `unan` n'est pas chargé (ce qui serait trop lourd car il serait
  # chargé à chaque chargement de page même lorsque l'utilisateur
  # ne se trouve pas dans la section du programme)
  def set_pastille_taches
    site.require_module 'pastille'
    ipastille = SiteHtml::Pastille::new
    # Procéder à l'état des lieux du programme UN AN UN SCRIPT et
    # retourner les valeurs utiles pour faire la pastille.
    ipastille.set data_pastille_etat_des_lieux
    ipastille.output
  end

  # Méthode qui retourne les données pour la pastille, c'est-à-dire
  # un hash contenant :
  #   :taches   Les tâches à afficher
  #   :title    Le titre à afficher quand on passe sur la pastille
  #   :nombre   Le nombre à afficher dans la pastille
  #   :css      La classe à donner à la pastille (en fait : la couleur du fond)
  #   :href     L'URL qu'il faut rejoindre pour voir les tâches.
  def data_pastille_etat_des_lieux
    # Pour obtenir les méthodes qui permettent de comparer
    # les travaux exécutés aux travaux non démarrés en utilisant
    # l'instance Unan::Program::CurPDay (current_pday)
    SuperFile::new('./objet/unan/lib/required/cur_pday').require
    SuperFile::new('./objet/unan/lib/required/program').require

    icp = Unan::Program::CurPDay::new( self.program.current_pday, self.id )

    nombre_travaux = icp.nombre_travaux_courant
    nombre_tasks_undone = icp.undone(:task).count
    nombre_pages_undone = icp.undone(:page).count
    nombre_quiz_undone  = icp.undone(:quiz).count
    nombre_tostart      = icp.undone(:all).count - icp.started(:all).count
    nombre_depassements = 0 # TODO: À RÉGLER

    taches = Array::new
    taches << "TRAVAUX UN AN UN SCRIPT".in_div(class:'underline bold')
    taches << "#{travaux_s nombre_travaux} en cours.".in_div(class:'bold') +
              "Tâches quelconques : #{nombre_tasks_undone}".in_div +
              "Pages de cours à lire : #{nombre_pages_undone}.".in_div +
              "Quiz à remplir : #{nombre_quiz_undone}.".in_div
    taches << if nombre_tostart > 0
      nombre_tasks_tostart  = icp.undone(:task).count  - icp.started(:task).count
      nombre_pages_tostart  = icp.undone(:page).count  - icp.started(:page).count
      nombre_quiz_tostart   = icp.undone(:quiz).count  - icp.started(:quiz).count
      nombre_forum_tostart  = icp.undone(:forum).count - icp.started(:forum).count
      (
        "#{travaux_s nombre_tostart} à amorcer :".in_div(class:'bold') +
        (nombre_tasks_tostart > 0 ? "  - Tâches à démarrer : #{nombre_tasks_tostart}".in_div : "") +
        (nombre_pages_tostart > 0 ? "  - Cours à marquer “vu” : #{nombre_pages_tostart}".in_div : '') +
        (nombre_forum_tostart > 0 ? "  - Messages       : #{nombre_forum_tostart}".in_div : '') +
        (nombre_quiz_tostart  > 0 ? "  - Quiz à remplir : #{nombre_quiz_tostart}".in_div : '')
      ).in_div(class:'red')

    else
      "Aucun travail à démarrer."
    end
    taches << "Échéance dépassée pour #{travaux_s nombre_depassements}.".in_span(class:'bold red') if nombre_depassements > 0

    css = if (nombre_tostart + nombre_depassements) > 0
      'red'
    else
      'green'
    end
    {taches: taches, title: nil, background: css, nombre: nombre_travaux, href:"bureau/home?in=unan"}
  end
  def travaux_s nombre
    "#{nombre} trava#{nombre > 1 ? 'ux' : 'il'}"
  end
end
