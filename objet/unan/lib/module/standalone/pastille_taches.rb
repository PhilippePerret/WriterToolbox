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
    # return ''
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
    site.require_objet('unan')

    icp = self.current_pday

    nombre_done     = icp.uworks_done.count
    nombre_undone   = icp.uworks_undone.count
    nombre_goon     = icp.uworks_goon.count
    nombre_unstart  = icp.aworks_unstarted.count
    nombre_nouveaux = icp.aworks_ofday.count
    nombre_overrun  = icp.uworks_overrun.count

    nombre_depuis_debut = icp.aworks_until_today.count

    # Le nombre total de travaux à faire, tous confondus
    nombre_travaux = nombre_depuis_debut - nombre_done

    # Le nombre de travaux à démarrer, en comptant les
    # travaux du jour s'ils ne sont pas démarrés
    # À quoi correspondent les travaux à démarrer ?
    # Ce sont
    nombre_a_demarrer = nombre_travaux - (nombre_undone + nombre_done)

    # nombre_works_in_table = self.table_works.count
    # debug "Nombre travaux dans la table : #{nombre_works_in_table}"

    taches = Array::new
    taches << "TRAVAUX UN AN UN SCRIPT".in_div(class:'underline bold')
    taches << "Travaux courants : #{nombre_travaux}".in_div(class:'bold') +
              "Poursuivis : #{nombre_goon}".in_div +
              "Nouveaux   : #{nombre_nouveaux}".in_div +
              "À démarrer : #{nombre_a_demarrer}.".in_div(class: (nombre_unstart > 0 ? 'red bold' : '')) +
              '<br>' +
              "Nombre depuis début : #{nombre_depuis_debut}".in_div(class: 'bold')

    if nombre_overrun > 0
      taches << "Dépassement : #{nombre_overrun}".in_div(class: 'red')
    end

    css =
      if (nombre_unstart + nombre_overrun) > 0
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
