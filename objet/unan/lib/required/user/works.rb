# encoding: UTF-8
class User
  # ---------------------------------------------------------------------
  # Retourne la liste de travaux de type +type+ qui
  # peut être :task, :quiz, :page ou :forum
  #
  # Sert aux panneaux du bureau, pour afficher les
  # travaux du type voulu.
  def uworks_undone_type type_expected
    h = {}
    uworks_undone.each do |kpaire, hw|
      type_w = hw[:options][0..1].to_i
      type_sym = Unan::Program::AbsWork::TYPES[type_w][:type] # p.e. :task
      next nil if type_sym != type_expected
      h.merge! kpaire => hw
    end
    return h
  end

  # Retourne la liste des travaux non démarrés de
  # type +type_expected+ qui peut être :task, :page,
  # :quiz ou :forum
  #
  #
  def aworks_unstarted_type type_expected
    h = {}
    aworks_unstarted.each do |kpaire, hw|
      type_sym = Unan::Program::AbsWork::TYPES[hw[:type_w]][:type] # p.e. :task
      next if type_sym != type_expected
      h.merge!(kpaire => hw)
    end
    return h
  end

  def uworks_recent_type type_expected
    h = {}
    pday = program.current_pday
    @uworks_done.each do |kpaire, huw|
      next if huw[:abs_pday] < (pday - 5)
      h.merge! kpaire => huw
    end
    return h
  end

  # ---------------------------------------------------------------------

  def aworks_unstarted
    define_aworks_unstarted if @aworks_unstarted === nil
    @aworks_unstarted
  end

  # {Hash} avec en clé la paire `abs_work_id-pday` et en
  # valeur les données du travail d'auteur tel qu'enregistré
  # dans la base de données
  def uworks_done
    define_uworks_done_and_undone if @uworks_done === nil
    @uworks_done
  end
  # {Hash} comme uworks_done mais pour les travaux qui ne
  # sont pas encore accomplis.
  def uworks_undone
    define_uworks_done_and_undone if @uworks_undone === nil
    @uworks_undone
  end
  def uworks_all
    define_uworks_done_and_undone if @uworks_all === nil
    @uworks_all
  end

  # ---------------------------------------------------------------------

  # ---------------------------------------------------------------------
  #   Méthodes utilitaires
  # ---------------------------------------------------------------------

  # Retourne la liste des tâches qui doivent être affichés
  # sur le bureau. Ce sont tous les tâches non achevés de
  # ce module avec les tâches récentes.
  #
  # Pour le moment on essaie de prendre ces tâches directement
  # ici
  def define_aworks_unstarted
    drequest = {
      where:  "id < #{program.current_pday}",
      colonnes: [:works]
    }
    @aworks_unstarted = {}
    # Boucle sur tous les jours-programmes jusqu'à aujourd'hui
    # Note : Il faudrait le faire pour tous les types de
    # tâches
    Unan.table_absolute_pdays.select(drequest).each do |hpday|
      next if hpday[:works].nil?
      pday = hpday[:id]
      wids = hpday[:works].split(' ')
      # On vérifie tous les travaux qui ne sont pas marqués
      wids.each do |awid|
        kpaire = "#{awid}-#{pday}"
        if uworks_all.key? kpaire
          # Ce travail est démarré
          next
        else
          @aworks_unstarted.merge!( kpaire => Unan.table_absolute_works.get(awid.to_i) )
        end
      end
    end
  end


  def define_uworks_done_and_undone
    @uworks_done    = {}
    @uworks_undone  = {}
    @uworks_all     = {}
    self.table_works.select.each do |hw|
      kpaire = "#{hw[:abs_work_id]}-#{hw[:abs_pday]}"
      @uworks_all.merge!(kpaire => hw)
      if hw[:status] == 9
        @uworks_done.merge!(kpaire => hw)
      else
        @uworks_undone.merge!(kpaire => hw)
      end
    end
  end

end #/User
