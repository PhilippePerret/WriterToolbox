# encoding: UTF-8
class Unan
class Program


  # Démarre le jour-programme suivant
  def start_next_pday
    start_pday( ( current_pday(:nombre) || 0 ) + 1 )
  end

  # Pour le développement du programme (implémentation), cette
  # méthode procède à quelques vérifications sur les 5 premiers
  # jours pour rectifier/corriger certaines choses qui changent
  # au cours de la programmation
  def check_validitie_program
    # Toutes les tables doivent exister

  end

  # Pour pouvoir les utiliser dans toutes les méthodes
  def abs_pday; @abs_pday end
  def pday    ; @pday     end
  def pday_with_new_travaux ; @pday_with_new_travaux end

  # Démarre le jour-programme d'index +ipday+ du programme courant
  #
  # NOTE
  # Cette méthode peut être appelée à n'importe quelle heure par
  # le cron-job pour faire passer au jour suivant, car la méthode
  # `test_if_next_pday` est appelée toutes les heures par le CRON job.
  # NOTE
  # Tous les p-days n'ont pas forcément de travail, donc un
  # changement de p-day peut se résumer à son changement d'index
  # dans le programme courant.
  # +ipday+ {Fixnum} Index du jour-programme à démarrer, de 1 à
  # 365
  def start_pday ipday

    # Pour la programmation et le développement, tant qu'on en est
    # pas au cinquième jour-programme, on procède à certaines
    # vérification d'usage pour rectifier le tir
    # La méthode vérifie par exemple que toutes les tables soient
    # bien construites
    check_validitie_program if ipday < 5

    # Instancier un AbsPDay pour ce jour
    # Mais ce jour-programme n'est peut-être pas défini,
    # ce qui signifie qu'aucun travail particulier n'est prévu
    # pour ce jour-là.
    @abs_pday = AbsPDay::new(ipday)

    @pday_with_new_travaux = @abs_pday.exist?

    # Si le jour-programme existe, on initialise un jour-programme
    # propre au programme pour ce jour-programme absolu
    # Noter que `abs_pday.id` ci-dessous correspond simplement
    # à l'indice du jour, donc 12 pour le 12e jour, etc.
    # Ce sera également l'ID du PDay propre au programme.
    @pday = PDay::new(self, ipday) if @pday_with_new_travaux

    # Si l'auteur veut recevoir un mail quotidien pour
    # lui rappeler ses travaux ou son état, il faut relever
    # la liste de ses travaux courants avant d'ajouter les
    # nouveaux travaux.
    # On les relève aussi même si l'auteur ne veux pas de mails
    # quotidien pour lui rappeler le travail qui reste à faire
    # après lui avoir présenté les nouveaux travaux
    if auteur.daily_summary? || @pday_with_new_travaux
      memorise_liste_travaux_courants_pour_mail
    end

    # On enregistre le jour-programme suivant dans la variable
    # `current_pday` de l'auteur, que ce jour-programme existe
    # ou non, car dans tous les cas il faut faire avancer l'auteur.
    # Noter que ce nombre, qui correspond à l'index du jour-programme,
    # donc un nombre de 1 à 365, est équivalent à l'ID du pday
    # ci-dessus, qu'on peut donc charger avec cet ID justement.
    # Comprendre : numéro = index = indice = id du jour-programme
    auteur.set_var :current_pday    => ipday.freeze

    # Il ne faut créer le p-day propre au programme et faire
    # les procédures suivantes que si ce jour-programme possède
    # un programme. Si c'est le cas, il faut relever tous les
    # travaux et les dispatcher dans les variables correspondantes
    # pour l'auteur
    if pday_with_new_travaux
      log "-- Des data sont définis (travaux) pour le jour #{ipday}"
      prepare_absolute_pday || return
    else
      log "-- Aucune donnée AbsPDay pour le jour #{ipday}"
      # Si l'auteur ne veut pas recevoir de mail journalier de
      # suivi, alors on peut tout de suite s'en retourner
      return unless auteur.daily_summary?
    end

    # On passe ici pour deux raisons :
    #   - Soit le jour-programme définit des nouveaux travaux dont
    #     il faut avertir l'auteur
    #   - Soit le jour-programme ne définit pas de nouveaux travaux
    #     mais l'auteur demande à être averti journalièrement

    send_mail_to_auteur

  end

  # Quand on doit envoyer un mail à l'auteur, donc soit s'il y a
  # de nouveaux travaux soit lorsque l'auteur désire recevoir des
  # mail journaliers
  def send_mail_to_auteur
    mail_name = case true
    when !pday_with_new_travaux
      # Mail de rappel de travail quand le jour-programme ne
      # définit pas de nouveaux travaux, pour un auteur qui en
      # a fait la demande (préférences)
      "mail_rappel_works"
    when pday_with_new_travaux && auteur.daily_summary?
      # Mail informant d'un jour-programme avec nouveaux travaux
      # + rappel des travaux courants pour un auteur qui veut être
      # informé quotidiennement
      "mail_new_works_et_rappel"
    when pday_with_new_travaux
      # Mail informant d'un jour-programme définissant de nouveaux
      # travaux pour un auteur qui ne reçoit pas les mail journaliers
      "mail_new_works"
    end + ".erb"

    mail_path = Unan::folder_module + "start_pday/#{mail_name}"
    message_mail = mail_path.deserb( self )
    log "Mail envoyé à #{auteur.pseudo} : #{mail_name}"

  end

  # Quand un jour-programme existe pour le jour-programme dans
  # lequel on vient de faire passer le programme, il faut le
  # traiter
  # +abs_pday+ Unan::Program::AbsPDay
  #
  def prepare_absolute_pday

    # On initialize la ou les listes qui vont servir notamment
    # à construire le mail à envoyer à l'auteur
    pday.init_messages_lists

    # Listes qui permettent de dispatcher les différents types
    # de travaux. Permet notamment de gérer les onglets du bureau
    # Ces listes seront enregistrées dans des variables de l'auteur,
    # en ajoutant `_ids` à la fin des clés utilisées ci-dessous.
    ids_lists = {
      works:  Array::new(), # contient tous les travaux
      pages:  Array::new(),
      quiz:   Array::new(),
      tasks:  Array::new(),
      forum:  Array::new(),
      none:   Array::new()
    }

    # Pour conserver la liste des titres de travaux pour
    # pouvoir l'insérer dans le mail
    works_titres = Array::new

    abs_pday.works(:as_instance).each do |work|

      # Les données de type de travail
      list_id = Unan::Program::AbsWork::TYPES[work.type_w][:id_list]

      # TODO Voir si le travail peut être accompli. Si sa donnée
      # prev_work est définie et que le travail précédent n'est pas
      # marqué fini, il faut l'indiquer. Au bout d'un certain temps,
      # il faut faire quelque chose.
      
      # On ajoute ce travail dans la liste adéquate
      ids_lists[list_id]  << work.id
      # On ajoute toujours le travail dans la liste de tous
      # les travaux
      ids_lists[:works]   << work.id
      # Pour le mail : le titre du travail
      works_titres << work.titre.in_li

    end

    # On enregistre les intitulés des nouveaux travaux
    pday.liste_nouveaux_travaux = works_titres.join("").in_ul(id: 'nouveaux_travaux')

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
    pday.save

  rescue Exception => e
    log "# ERREUR FATALE : #{e.message}"
    log "# MALHEUREUSEMENT, IL EST IMPOSSIBLE DE DÉTERMINER LA LISTE DES NOUVEAUX TRAVAUX…"
  else
    true # pour poursuivre
  end


  # Méthode qui mémorise les travaux courants de l'auteur pour
  # le mail. Soit parce qu'il veut recevoir un mail quotidien, soit
  # parce que c'est un nouveau jour-programme (donc de nouveaux
  # travaux) et qu'on rappelle toujours les travaux courants dans
  # ce cas
  # TODO Dans cette méthode, il faudrait également voir si des
  # travaux ne devraient pas déjà être accomplis, qui ne le sont
  # pas (comment le savoir ?) et les signalier le cas échéant.
  def memorise_liste_travaux_courants_pour_mail

    # La liste des IDs de tous les travaux (works) courant de
    # l'auteur
    works_ids = auteur.get_var(:works_ids, nil)

    # Dans le cas où l'auteur n'a plus aucun travail à faire
    return if works_ids.nil?

    travaux_courants = works_ids.collect do |wid|
      iabs_work = Unan::Program::AbsWork::get(wid)
      iwork     = self.work(wid)
      # On termine par le titre pour le collect de
      # la boucle
      iabs_work.titre.in_li
    end.join

    pday.liste_travaux_courants = travaux_courants

  end

end #/Program
end #/Unan
