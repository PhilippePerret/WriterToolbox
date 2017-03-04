# encoding: UTF-8
class Console
  def check_auteurs args
    auteur_ref = args.delete(:ref_auteur)

    console.output "Check des auteurs du programme UNAN.".in_h3
    auteurs_ids = Array.new
    if auteur_ref != nil
      if auteur_ref.numeric?
        auteurs_ids << auteur_ref.to_i
      else
        auteur_id = User.table.select(where: "pseudo = '#{auteur_ref}'", colonnes: [])
        auteur_id.empty? && raise("Impossible de trouver l'auteur de pseudo #{auteur_ref}…")
        auteur_id = auteur_id.first[:id]
        auteurs_ids << auteur_id
      end
    else
      # On doit récupérer tous les auteurs du programme UNAN
      # pour les traiter.
      programs = Unan.table_programs.select(where: "options LIKE '1%'", colonnes: [:auteur_id])
      auteurs_ids = programs.collect{|h| h[:auteur_id]}
    end
    # console.output "IDs des auteurs des programmes actifs : #{auteurs_ids}"

    # On boucle sur chaque auteur actif
    an_error_has_been_found = false
    auteurs_ids.each do |auteur_id|
      iauteur = Console::Auteur.new(auteur_id)
      iauteur.check(repare = args[:repare])
      if iauteur.error_has_found
        an_error_has_been_found = true
      end
    end

    an_error_has_been_found && begin
      error "UNE ERREUR A ÉTÉ TROUVÉE.<br><br>Pour la corriger, rejouer la commande en ajoutant `--repare` au bout (par exemple `check auteurs --repare`)."
    end
  rescue Exception => e
    debug e
    error e.message
  end


  # ---------------------------------------------------------------------
  #   Console::Auteur
  # ---------------------------------------------------------------------


  class Auteur
    # Identifiant de l'auteur suivant le programme UNAN
    attr_reader :id

    # Mis à true si une erreur a été trouvée
    attr_reader :error_has_found

    # Mis à true s'il faut réparer les erreurs trouvées
    attr_reader :and_repare

    def initialize auteur_id
      @id = auteur_id
    end

    def day
      @day ||= program.current_pday
    end

    # = main =
    # Méthode principale checkant l'auteur
    def check and_repare
      @and_repare = and_repare
      m "Check de #{pseudo} (##{id})".upcase.in_div(class: 'bold')
      m "<pre style='margin-top:0;margin-bottom:4em'>"
      begin
        mpre "Programme ID" , program.id
        mpre "Rythme"       , program.rythme
        mpre "Début (create program)", program.created_at.as_date
        mpre "Jour-programme courant", program.current_pday
        mpre "Début du jour-programme courant", program.current_pday_start.as_date
        informations_generales_travaux
        check_travaux
      rescue Exception => e
        debug e
        error e.message
      ensure
        m "</pre>"
      end
    end

    def delimitation titre = nil
      m "\n"
      m '-'*50
      titre.nil? || m(titre.upcase.in_div(class: 'bold'))
    end

    def informations_generales_travaux
      delimitation
      mpre 'NOMBRE TOTAL DE TRAVAUX', cday.aworks_until_today.count
      m    'Nombre de travaux…'
      mpre '              courants'     , cday.uworks_undone.count
      # mpre '              démarrés', cday.
      mpre '              du jour'      , cday.aworks_ofday.count
      mpre '              non démarrés' , cday.aworks_unstarted.count
      mpre '              en dépassement' , cday.uworks_overrun.count
    end

    def check_travaux
      check_travaux_overrun
      check_travaux_courants
    end

    # Vérifie les travaux en dépassement
    def check_travaux_overrun
      delimitation 'Travaux en dépassement'
      cday.uworks_overrun.each do |hw|
        pday_fin = hw[:pday] + hw[:duree]
        m "Travail overrun ##{hw[:id]}"
        mpre '       Jour-programme', hw[:pday]
        mpre '       Durée', "#{hw[:duree]} jours"
        mpre '       PDay de fin', pday_fin
        mpre '       Dépassement', "#{hw[:overrun]} (#{day} - #{pday_fin})"

        # Travail relatif correspondant. On va vérifier que
        # ses données soient correctes, par exemple que son started_at
        # corresponde bien même après un changement de rythme.
        uwork_id = hw[:uwork_id]
        uwork = Unan::Program::Work.new(program, uwork_id)

        m    '    Travail relatif'
        mpre '       Démarrage', uwork.created_at.as_date

        # On calcule le created_at attendu par rapport au
        # jour programme courant et par rapport au jour-programme
        # du programme
        started_since = day - hw[:pday]
            # par exemple, si on en est au 20e jour-programme (day)
            # et que le travail devait être commencé le 13e jourp,
            # (hw[:pday]), alors le travail doit être commencé
            # depuis 7 jours (started_since)
        mpre '       Doit être commencé depuis', "#{started_since} jours-p"
        # On compte depuis combien de secondes, en fonction du
        # rythme, ce travail aurait dû être démarré
        real_started_since = to_real_duree(started_since * 1.days)
        # On compte, par rapport au rythme, le jour réel auquel
        # cela doit correspondre
        real_started_date  = Time.now.to_i - real_started_since
        mpre '       Ce qui correspond à la date du', real_started_date.as_date
        # On compte le décalage de jours entre la date de démarrage
        # du travail relatif (work) et la date normalement donnée
        # par rapport à la date du travail.
        diff_secondes = (uwork.created_at - real_started_date).abs
        diff_jours = diff_secondes / 1.day
        if diff_jours > 1
          # Si la différence de jours est supérieure à 1, c'est que
          # la date de démarrage du travail ne correspond pas.
          # ATTENTION ! Pour le moment, cela sera vrai quand l'auteur
          # démarrera un travail en retard. TODO Que faut-il faire ?
          # Dans l'idéal, on ne doit pas tenir compte de ce retard, le
          # démarrage devrait toujours se faire en temps et en heure.
          m "Il y a une différence de #{diff_jours} jours. Il faut corriger cette date".in_div(class:'red bold')
          if and_repare
            uwork.set(created_at: real_started_date)
            m "   Cette erreur a été réparée en modifiant la date de départ du travail.".in_div(class: 'blue')
          else
            error_found
          end
        end
      end
    end


    def check_travaux_courants
      delimitation 'Travaux courants'
      cday.uworks_undone.each do |hw|
        m "Travail courant ##{hw[:awork_id]} (work ##{hw[:uwork_id]})"
      end
    end


    # ---------------------------------------------------------------------
    #   Méthodes fonctionnelles
    # ---------------------------------------------------------------------
    def m message
      console.output message
    end
    def mpre label, valeur
      m "#{label.ljust(40,'.')} #{valeur}"
    end

    # Pour signaler une erreur trouvée
    # Cela permettra de signaler qu'il y a eu des erreurs et
    # d'indiquer comment les corriger
    def error_found
      @error_has_found = true
    end
    # ---------------------------------------------------------------------
    #   Data
    # ---------------------------------------------------------------------
    def method_missing method, *args, &block
      if user_instance.respond_to?(method.to_sym)
        user_instance.send(method.to_sym)
      else
        raise "Méthode inconnue, même par l'instance user : #{method}"
      end
    end

    # Jour programme courant (instance)
    def cday
      @cday ||= user_instance.current_pday
    end
    def to_real_duree dur
      (dur * coef_duree).to_i
    end
    def coef_duree
      @coef_duree ||= program.coefficient_duree
    end
    def program
      @program ||= user_instance.program
    end
    def user_instance
      @user_instance ||= User.new(id)
    end
  end
end #/Console
