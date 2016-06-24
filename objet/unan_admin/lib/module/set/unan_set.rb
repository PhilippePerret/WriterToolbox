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
      reset_all
      # Réglage des données du programme en fonction
      # des choix. Noter que le nombre de points sera
      # recalculé dans la suite.
      set_program_data
      # Réglage des travaux exécutés
      set_done_works
      flash "Programme 1A1S de #{auteur.pseudo} resetté au jour-programme #{args[:pday]}"
    end

    # ---------------------------------------------------------------------

    # Reset complet de l'auteur
    def reset_all
      recreate_table_works
    end

    def coef_duree
      @coef_duree ||= 5.0 / args[:rythme]
    end

    def set_program_data
      created_at = NOW - (args[:pday] * coef_duree )
      new_data = {
        current_pday:         args[:pday],
        current_pday_start:   NOW,
        rythme:               args[:rythme],
        created_at:           created_at,
        updated_at:           NOW,
        points:               args[:points]
      }
      auteur.program.set(new_data)
    end

    # Réglage des travaux effectués
    def set_done_works
      return if args[:done_upto].nil?
      upto = args[:done_upto]
      upto <= args[:pday] || raise('La valeur `done_upto` doit être inférieure ou égale au jour-programme courant, voyons.')
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
          dtime = NOW - ((args[:pday] - this_pday).days * coef_duree)
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
    end

    # ---------------------------------------------------------------------

    def recreate_table_works
      table_works = site.dbm_table(:users_tables, "unan_works_#{auteur.id}")
      table_works.destroy
      table_works.create
    end

    # ---------------------------------------------------------------------
    #   Réglage du programme en fonction des arguments
    # ---------------------------------------------------------------------
    # Réglage du jour-programme courant
    def set_pday
      auteur.program.current_pday = args[:pday]
    end

  end #/UnanSet
end #/User
