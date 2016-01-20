# encoding: UTF-8
class Unan
class Program


  # Démarre le jour-programme suivant
  # Méthode générale qui va faire passer le programme courant
  # du jour courant au jour suivant.
  # Noter que suivant le rythme du programme, cela peut survenir
  # n'importe quand, à n'importe quelle heure.
  def start_next_pday
    start_pday( ( current_pday(:nombre) || 0 ) + 1 )
    StarterPDay::new(self).next_pday
  end

  # Pour le développement du programme (implémentation), cette
  # méthode procède à quelques vérifications sur les 5 premiers
  # jours pour rectifier/corriger certaines choses qui changent
  # au cours de la programmation
  def check_validite_program
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
    begin
      check_validite_program if ipday < 5
    rescue Exception => e
      log "# Impossible de vérifier la validité du program : #{e.message}"
    end

    # Instancier un AbsPDay pour ce jour
    # Mais ce jour-programme n'est peut-être pas défini,
    # ce qui signifie qu'aucun travail particulier n'est prévu
    # pour ce jour-là.
    @abs_pday = AbsPDay::new(ipday)

    # Variable qui permet de savoir s'il y a des travaux pour
    # ce jour-programme. Quand le jour-programme absolu existe,
    # c'est qu'il y a forcément des travaux.
    @pday_with_new_travaux = @abs_pday.exist?

    # Si le jour-programme existe, on initialise un jour-programme
    # propre au programme pour ce jour-programme absolu
    # Noter que `abs_pday.id` ci-dessous correspond simplement
    # à l'indice du jour, donc 12 pour le 12e jour, etc.
    # Ce sera également l'ID du PDay propre au programme.
    @pday = PDay::new(self, ipday) # if @pday_with_new_travaux

    # On commence par un contrôle de l'état du programme
    # On regarde si les travaux sont faits dans les temps et
    # on signale à l'auteur les éventuels retards, avec une
    # gradation en fonction du nombre de rappels et des conseils
    # différents.
    # Quel que soit le choix de l'auteur (mails journaliers ou non,
    # il sera averti de ses retards)
    # Noter que tous ces messages sont ajoutés à l'instance @pday
    # créée ci-dessus, par commodité.
    # Mais ce @pday ne sera créé que s'il y a des travaux (vraiment ?
    # ou alors on consigne aussi les problèmes, justemnet ?)
    # Cette méthode prépare aussi le mail journalier, puisqu'elle
    # va passer en revue tous les travaux courants de l'auteur.
    begin
      check_current_etat_travail_programme
    rescue Exception => e
      log "# ERREUR GRAVE : Impossible de vérifier l'étape du travail du programme courant (#{id}) : #{e.message}"
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
      begin
        prepare_absolute_pday || return
      rescue Exception => e
        log "# Impossible de préparer le jour-programme absolu : #{e.message}."
      end
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
    begin
      send_mail_to_auteur
    rescue Exception => e
      log "#GRAVE ERREUR : Impossible d'envoyer le mail à l'auteur du programme ##{id} (#{auteur.pseudo}/##{auteur.id}) : #{e.message}."
    end

  end


  # Méthode qui vérifie l'état de travail de l'auteur et
  # prépare des messages d'avertissement à l'auteur s'il est
  # en retard.
  # + Préparation du mail pour l'auteur qui veut un mail
  # journalier.
  def check_current_etat_travail_programme


    # Pour conserver les instances Unan::Program::Work parce
    # qu'on en aura besoin pour voir si un travail peut être
    # mené après un autre
    @travaux = Hash::new

    # On passe ici si l'auteur a encore des travaux à effectuer
    # Il faut regarder s'il n'est pas en dépassement du temps.
    titre_travaux_courants = works_ids.collect do |wid|

      # L'instance du travail du programme
      iwork     = self.work(wid)
      @travaux.merge!( wid => iwork )

      if iwork.depassement?

        # Si le programme est en dépassement, il faut le mémoriser
        # pour faire une alerte à l'auteur.
        # Et une alerte à l'administration si ça dépasse un niveau
        # d'avertissements.

        case true
        when iwork.depassament < 3.days
          # Premier avertissement, lorsque le travail était de la veille
          # ou l'avant-veille
          # Donc jour 1 à 2 supplémentaires
          niveau_avertissement = 1

        when iwork.depassement < 7.days
          # Second avertissement, lorsque le travail aurait dû être
          # fait 3 jours avant jusque fin de semaine
          # Donc : jours 3 à 7 supplémentaires
          niveau_avertissement = 2

        when iwork.depassement < 15.days
          # 3e avertissement, lorsque le travail devait être fait dans
          # la semaine jusque 15 jours
          # Donc : de jour 8 à jour 15
          # Note : Un mail est également envoyé à l'administration
          niveau_avertissement = 3

        when iwork.depassement < 31.days
          # 4e avertissement, lorsque le travail devait être fait dans
          # le mois
          # Donc : de jour 16 à 31
          # Note : Un mail est également envoyé à l'administration
          niveau_avertissement = 4

        when iwork.depassement < 47.days
          # 5e avertissement, lorsque le travail n'a pas été fait
          # dans le mois.
          # Donc : de jour 32 à plus
          # Note : Un mail est également envoyé à l'administration
          niveau_avertissement = 5

        else
          # Dernier avertissement. L'alerte maximale a été donnée 15
          # jour auparavant, sans réponse et sans changement, l'auteur
          # est considéré comme démissionnaire, on l'arrête.
          # Donc depuis jours 47
          # Note : Un mail est également envoyé à l'administration
          niveau_avertissement = 6

        end

        # Incrémentation du nombre de travaux en dépassement
        # d'échéance
        avertissements[:total] += 1

        # Ajout du travail à son niveau d'avertissement
        avertissements[niveau_avertissement] << iwork

        if niveau_avertissement > 2
          avertissement_administration = true
          if niveau_avertissement > 4
            avertissements[:greater_than_four] += 1
          end
        end

      end # / fin si le travail est en dépassement

      # On termine par le titre pour le collect de
      # la boucle qui ramasse les titres de tous les travaux
      iwork.abs_work.titre.in_li(class: (iwork.depassement? ? 'warning' : nil))
    end.join # / fin de boucle sur tous les travaux courants

    # On ne fait quelque chose de radical que lorsqu'il
    # y a un certain nombre de travaux en retard. Si 5
    # travaux ont dépassé le niveau 4, c'est qu'il y a
    # vraiment un problème avec l'auteur
    key_message = case true
    when avertissements[:greater_than_four] > 5
      :trop_de_depassement
    when avertissements[:total] > 0
      :depassement
    else # avertissements[:total] == 0
      :non_depassement # => Un mot d'encouragement
    end
    pday.message_depassement = Unan::choose_message(key_message)

    if avertissement_administration
      # On n'envoie pas tout de suite le mail, car il rassemble
      # en un seul mail tous les auteurs qui ont des travaux en
      # retard (sinon, les mails risquent d'être trop nombreux)
      Unan::rapport_administration[:depassements] << "#{auteur.pseudo} (##{auteur.id}) est en dépassement important (travaux en dépassement d'échéance : #{avertissements[:total]}, travaux en dépassement de plus d'un mois : #{avertissements[:greater_than_four]})"
    end



    pday.liste_travaux_courants = titre_travaux_courants

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
      "rappel_works"
    when pday_with_new_travaux && auteur.daily_summary?
      # Mail informant d'un jour-programme avec nouveaux travaux
      # + rappel des travaux courants pour un auteur qui veut être
      # informé quotidiennement
      "new_works_et_rappel"
    when pday_with_new_travaux
      # Mail informant d'un jour-programme définissant de nouveaux
      # travaux pour un auteur qui ne reçoit pas les mail journaliers
      "new_works"
    end

    mail_path = Unan::folder_module + "start_pday/mail/#{mail_name}.erb"
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
    pday.create

  rescue Exception => e
    log "# ERREUR FATALE : #{e.message}"
    log "# MALHEUREUSEMENT, IL EST IMPOSSIBLE DE DÉTERMINER LA LISTE DES NOUVEAUX TRAVAUX…"
  else
    true # pour poursuivre
  end


end #/Program
end #/Unan
