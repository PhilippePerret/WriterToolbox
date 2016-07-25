# encoding: UTF-8
class User

  # +args+ Cf. le fichier READ ME
  def unan_set args
    UnanSet.new(self, args).proceed
  end

  class UnanSet
    attr_reader :auteur
    attr_reader :args
    def initialize auteur, args
      @args   = args
      @auteur = auteur
      set_default_values
    end

    def log mess
      begin
        console.sub_log "#{mess}\n"
      rescue
        debug mess
      end
    end

    # Méthode qui applique les valeurs par défaut
    def set_default_values
      args.key?(:pday)          || @args.merge!(pday: 1)
      args.key?(:rythme)        || @args.merge!(rythme: 5)
      args.key?(:points)        || @args.merge!(points: 0)
      args.key?(:nombre_undone) || @args.merge!(nombre_undone: 0)
    end

    # =======================
    #  Procède à l'opération
    # =======================
    def proceed
      log "<pre style='white-space: pre-wrap;font-size:12pt;'>"
      log "Préparation d'un d'auteur UN AN UN SCRIPT"
      log "Auteur : #{auteur.pseudo}"
      reset_all
      # Réglage des données du programme en fonction
      # des choix. Noter que le nombre de points sera
      # recalculé dans la suite.
      set_program_data
      # Réglage des travaux exécutés
      set_done_works
      flash "Programme 1A1S de #{auteur.pseudo} resetté au jour-programme #{args[:pday]}"
      log '</pre>'
    end

    # ---------------------------------------------------------------------

    def pday
      @pday ||= args[:pday] || auteur.program.current_pday
    end

    # Reset complet de l'auteur
    def reset_all
      log "-> reset_all"
      recreate_table_works
      recreate_table_pages_cours
      recreate_table_quiz
      recreate_paiement
      log "<- reset_all"
    end

    def coef_duree
      @coef_duree ||= 5.0 / args[:rythme]
    end

    def set_program_data
      log "-> set_program_data"
      created_at = NOW - (pday.days * coef_duree )
      new_data = {
        current_pday:         pday,
        current_pday_start:   NOW,
        rythme:               args[:rythme],
        created_at:           created_at,
        updated_at:           NOW,
        points:               args[:points]
      }
      auteur.program.set(new_data)
      log "<- set_program_data"
    end

    # Réglage des travaux effectués
    def set_done_works
      return if args[:done_upto].nil?
      log "-> set_done_works"
      upto = args[:done_upto]
      upto <= pday || raise('La valeur `done_upto` doit être inférieure ou égale au jour-programme courant, voyons.')
      undones = args[:nombre_undone]
      nombre_points = 0
      Unan.table_absolute_pdays.select(where: "id <= #{args[:done_upto]}").each do |hpday|
        this_pday = hpday[:id]
        works     = hpday[:works]
        next if works.nil?
        works = works.split(' ').collect{|e| e.to_i}
        works.each do |wid|
          awork = Unan::Program::AbsWork.new(wid)
          nombre_points += awork.points || 0
          # Faire un enregistrement dans la table des travaux
          dtime = NOW - ((pday - this_pday).days * coef_duree)
          data_work = {
            program_id:     auteur.program.id,
            abs_work_id:    awork.id,
            abs_pday:       this_pday,
            status:         9,
            options:        haw[:options],
            created_at:     dtime,
            updated_at:     dtime + 1000,
            ended_at:       dtime + 3000,
            points:         awork.points
          }
          auteur.table_works.insert(data_work)
        end
      end
      @args[:points] = nombre_points
      log "<- set_done_works"
    end

    # ---------------------------------------------------------------------

    def recreate_table_works
      log "* Destruction et reconstruction de la table des works de l'auteur…"
      table_works = site.dbm_table(:users_tables, "unan_works_#{auteur.id}")
      table_works.destroy if table_works.exist?
      table_works.create
      log "  = OK"
    end

    def recreate_table_pages_cours
      log "* Destruction et reconstruction de la table des pages de cours de l'auteur…"
      table_pages_cours = auteur.table_pages_cours
      # table_pages_cours = site.dbm_table(:users_tables, "unan_pages_cours_#{auteur.id}")
      table_pages_cours.destroy if table_pages_cours.exist?
      table_pages_cours.create
      log "  = OK"
    end
    def recreate_table_quiz
      log "* Destruction et reconstruction de la table des questionnaires de l'auteur…"
      table_quiz = auteur.table_quiz
      table_quiz.destroy if table_quiz.exist?
      table_quiz.create
      log "  = OK"
    end
    def recreate_paiement
      log "* Recréation du paiements"
      User.table_paiements.delete(where: {user_id: auteur.id})
      now = (NOW - (pday.days * coef_duree))
      data_paiement = {
        user_id:    auteur.id,
        montant:    19.8,
        objet_id:   '1AN1SCRIPT',
        created_at: now,
        facture:    'EC-08R60522T08193748'
      }
      User.table_paiements.insert(data_paiement)

      User.table_autorisations.delete(where: "user_id = #{auteur.id} && raison = '1AN1SCRIPT'")
      data_autorisation = {
        user_id: auteur.id,
        raison: "1AN1SCRIPT",
        start_time:     now,
        end_time:       (now) + (2.years),
        created_at:     now,
        updated_at:     now,
        nombre_jours:   (2 * 365)
      }
      User.table_autorisations.insert(data_autorisation)

      log "  = OK"
    end

    # ---------------------------------------------------------------------
    #   Réglage du programme en fonction des arguments
    # ---------------------------------------------------------------------
    # Réglage du jour-programme courant
    def set_pday
      auteur.program.current_pday = pday
    end

  end #/UnanSet
end #/User
