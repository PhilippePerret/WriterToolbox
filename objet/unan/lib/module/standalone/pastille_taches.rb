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
    # return ""
    # QUESTION : Comment faire pour que ces tâches soient utilisables
    # sur n'importe quel site et pas seulement ici ?

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
    # MAINTENANT, j'essaie de me débrouiller seulement avec
    # l'instance Unan::Program::CurPDay qui peut tout
    # calculer

    # etat_des_lieux_programme_unan
    # inv = @unan_inventory
    # taches = Array::new
    # taches << "TRAVAUX UN AN UN SCRIPT".in_span(class:'underline')
    # taches << "#{travaux_s inv[:nombre_travaux]} en cours."
    # taches << "Pages de cours à lire : #{inv[:nombre_pages_cours]}."
    # taches << "Quiz à remplir : #{inv[:nombre_quiz]}."
    # taches << if inv[:nombre_travaux_not_started] > 0
    #   "#{travaux_s inv[:nombre_travaux_not_started]} à démarrer.".in_span(class:'bold red')
    # else
    #   "Aucun travail à démarrer."
    # end
    # taches << "Échéance dépassée pour #{travaux_s inv[:nombre_travaux_overtimed]}.".in_span(class:'bold red') if inv[:nombre_travaux_overtimed] > 0

    # Pour obtenir les méthodes qui permettent de comparer
    # les travaux exécutés aux travaux non démarrés en utilisant
    # l'instance Unan::Program::CurPDay (current_pday)
    SuperFile::new('./objet/unan/lib/required/cur_pday').require
    SuperFile::new('./objet/unan/lib/required/program').require

    icurpday = Unan::Program::CurPDay::new( self.program.current_pday, self.id )

    nombre_travaux = icurpday.nombre_travaux_courant
    nombre_tasks_encours  = icurpday.undone_tasks.count
    nombre_pages_encours  = icurpday.undone_pages.count
    nombre_quiz_encours   = icurpday.undone_quiz.count
    nombre_unstarted      = icurpday.works_undone.count - icurpday.works_started.count
    nombre_depassements = 0 # TODO: À RÉGLER

    taches = Array::new
    taches << "TRAVAUX UN AN UN SCRIPT".in_span(class:'underline')
    taches << "#{travaux_s nombre_travaux} en cours."
    taches << "Tâches quelconques : #{nombre_tasks_encours}"
    taches << "Pages de cours à lire : #{nombre_pages_encours}."
    taches << "Quiz à remplir : #{nombre_quiz_encours}."
    taches << if nombre_unstarted > 0
      "#{travaux_s nombre_unstarted} à démarrer.".in_span(class:'bold red')
    else
      "Aucun travail à démarrer."
    end
    taches << "Échéance dépassée pour #{travaux_s nombre_depassements}.".in_span(class:'bold red') if nombre_depassements > 0

    css = if (nombre_unstarted + nombre_depassements) > 0
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
