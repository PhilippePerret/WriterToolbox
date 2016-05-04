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
    etat_des_lieux_programme_unan
    inv = @unan_inventory
    taches = Array::new
    taches << "TRAVAUX UN AN UN SCRIPT".in_span(class:'underline')
    taches << "#{travaux_s inv[:nombre_travaux]} en cours."
    taches << "Pages de cours à lire : #{inv[:nombre_pages_cours]}."
    taches << "Quiz à remplir : #{inv[:nombre_quiz]}."
    taches << if inv[:nombre_travaux_not_started] > 0
      "#{travaux_s inv[:nombre_travaux_not_started]} à démarrer.".in_span(class:'bold red')
    else
      "Aucun travail à démarrer."
    end
    taches << "Échéance dépassée pour #{travaux_s inv[:nombre_travaux_overtimed]}.".in_span(class:'bold red') if inv[:nombre_travaux_overtimed] > 0

    css = if (inv[:nombre_travaux_not_started] + inv[:nombre_travaux_overtimed]) > 0
      'red'
    else
      'green'
    end
    {taches: taches, title: nil, background: css, nombre: inv[:nombre_travaux], href:"bureau/home?in=unan"}
  end
  def travaux_s nombre
    "#{nombre} trava#{nombre > 1 ? 'ux' : 'il'}"
  end

  # Méthode qui produit un état des lieux de l'user pour son
  # programme UN AN UN SCRIPT
  # Permet de définir des propriétés volatiles contenant tous
  # les résultats dans @unan_inventory
  # Noter que cet état des lieux peut se faire sans que l'objet
  # unan soit chargé, puisque le module travail en standalone
  def etat_des_lieux_programme_unan
    # La variable d'instance qui contiendra tous les états
    @unan_inventory = Hash::new
    @unan_inventory.merge!(
      # Le nombre total de travaux en cours (démarrés ou non)
      nombre_travaux: 0,
      # La liste des identifiants des travaux en cours
      travaux_ids: Array::new,
      # Nombre de travaux non démarrés (tout confondu)
      nombre_travaux_not_started: 0,
      # {Hash} Données des travaux non démarrés
      # Clé = ID du travail, Value = Hash des données du travail
      travaux_not_started:        Hash::new,
      # Nombre de travaux dont l'échéance a été dépassée
      nombre_travaux_overtimed:   0,
      # {Hash} Données des travaux d'échéance dépassée
      travaux_overtimed:          Hash::new,
      # Nombre de travaux OK
      nombre_travaux_ok: 0,
      # {Hash} Données des travaux en cours OK
      travaux_ok: Hash::new,
      nombre_quiz: 0,
      quiz: Hash::new,
      nombre_pages_cours: 0,
      pages_cours: Hash::new
    )

    # Pour obtenir les paths des bases de données et autres
    # tables
    require './objet/unan/lib/required/unan/class_database.rb'

    # Pour obtenir le rythme et le coefficiant durée du programme
    require './objet/unan/lib/required/program/inst.rb'
    require './objet/unan/lib/required/program/data.rb'

    # Pour obtenir les méthodes qui permettent de comparer
    # les travaux exécutés aux travaux non démarrés en utilisant
    # l'instance Unan::Program::CurPDay (current_pday)
    SuperFile::new('./objet/unan/lib/required/cur_pday').require

    raise "Vous n'avez aucun programme courant, étrange…" if programme_id.nil?
    # debug "ID programme UN AN UN SCRIPT user ##{id} : #{programme_id}"
    iprogram = Unan::Program::new(programme_id)
    path_db = site.folder_db + "unan/user/#{user.id}/programme#{programme_id}.db"
    raise "La db de votre programme courant est introuvable… (#{path_db})" unless path_db.exist?


    # Instance {Unan::Program:CurPDay} qui permet de gérer les
    # travaux avec la nouvelle formule qui n'enregistre des
    # instances Work que lorsque l'auteur démarre le travail
    # Permettra d'utiliser :
    #   icurpday.undone_tasks et compagnie
    icurpday = Unan::Program::CurPDay::new(iprogram.current_pday, self.id)


    # Ici, on a toutes les informations pour récupérer les travaux.
    # Noter que maintenant, seuls les travaux commencés (démarrés)
    # possèdent une instance Work. Donc il faut vérifier les travaux
    # qui existent au moment où on appelle ce module.
    colonnes  = [:status, :abs_work_id, :abs_pday, :created_at]
    # Note : dans la clause WHERE, il faut passer les travaux qui
    # sont programmés dans le futur.
    where     = "status < 9 AND created_at <= #{NOW}"
    hworks = BdD::new(path_db.to_s).table('works').select(where:where, colonnes:colonnes)
    debug "Travaux relevés dans base : #{hworks.pretty_inspect}"


    # On récupère quelques données absolues des travaux qui serviront
    # pour faire l'état des lieux
    aworks_ids = hworks.collect { |wid, wdata| wdata[:abs_work_id] }
    where     = "id IN (#{aworks_ids.join(', ')})"
    colonnes  = [:titre, :duree, :type_w]
    habsworks = Unan::table_absolute_works.select(where:where, colonnes:colonnes)

    # Requérir le module qui contient de nombreuses listes
    # et hash en constante, et notamment, utile ci-dessous :
    # Unan::Program::AbsWork::TYPES
    require './data/unan/data/listes.rb'

    # Les travaux non terminés
    hworks.each do |wid, wdata|
      awork_id = wdata[:abs_work_id]
      # Les données complètes, avec le titre du travail et la durée
      # récupérée dans les données absolues du travail.
      full_wdata = wdata.merge(habsworks[awork_id])

      # Est-ce que l'échéance de ce travail est dépassée ?
      # Noter qu'il faut tenir compte du rythme de travail
      # de l'user.
      # Noter qu'on prendre :created_at en référence mais que
      # ce temps ne considère pas le temps de démarrage de
      # l'user. Le problème, c'est que si l'on prendre :updated_at
      # on risque d'avoir une donnée fausse car :updated_at sera
      # actualisé pour n'importe quelle autre modification.
      duree_travail = (iprogram.coefficient_duree * full_wdata[:duree].days).to_i
      fin_travail_expected = full_wdata[:created_at] + duree_travail
      is_overtimed = NOW > fin_travail_expected

      # Le type de travail, pour savoir si c'est un travail à démarrer,
      # une page à lire, etc.
      # La donnée TYPES ci-dessous est définies dans
      # './data/unan/data/listes.rb'
      type_w = full_wdata[:type_w]
      type_w = Unan::Program::AbsWork::TYPES[type_w][:id_list]
      # => :tasks, :pages, :quiz, :forum

      @unan_inventory[:travaux_ids]     << wid
      @unan_inventory[:nombre_travaux]  += 1

      if is_overtimed
        # <= Un travail dont l'échéance est dépassée
        @unan_inventory[:nombre_travaux_overtimed] += 1
        @unan_inventory[:travaux_overtimed].merge!(wid => full_wdata)
      else
        # <= Un travail en cours normal, ok
        @unan_inventory[:nombre_travaux_ok] += 1
        @unan_inventory[:travaux_ok].merge!(wid => full_wdata)
      end
    end # / fin boucle sur tous les travaux en cours de l'user

    # On ajoute tous les travaux non démarrés
    @unan_inventory[:nombre_travaux_not_started] += icurpday.works_undone(as: :ids).count

    @unan_inventory[:nombre_travaux] += @unan_inventory[:nombre_travaux_not_started]
    # # icurpday.undone_tasks.each do |hwork|
    # #   @unan_inventory[:travaux_not_started].merge!(hwork[:id] => hwork)
    # # end
    # @unan_inventory[:nombre_quiz] += icurpday.undone_quiz.count
    # # @unan_inventory[:quiz].merge!(wid => wdata)
    # @unan_inventory[:nombre_pages_cours] += icurpday.undone_pages.count
    # # @unan_inventory[:pages_cours].merge!(wid => wdata)
    # @unan_inventory[:nombre_forum] + icurpday.undone_forum.count


    # debug "\n\n@unan_inventory total : #{@unan_inventory.pretty_inspect}\n\n"
  rescue Exception => e
    debug e
    ""
  end

  # {Fixnum} Retourne l'ID du programme actuellement suivi par
  # l'user, pour construire le path de la base de données de ce
  # programme.
  # Noter qu'on n'utilise pas `program_id` pour ne pas interférer
  # avec la méthode `user.program_id` du programme UN AN UN SCRIPT
  # qui peut être chargé quand ce module n'est pas vraiment en
  # "standalone" (ce qui arrive chaque fois que l'user se trouve
  # dans la section du programme).
  def programme_id
    @programme_id ||= begin
      hdata = Unan::table_programs.select(where:"auteur_id = #{user.id} AND options LIKE '1%'", colonnes:[:id]).values.first
      hdata.nil? ? nil : hdata[:id]
    end
  end
end
