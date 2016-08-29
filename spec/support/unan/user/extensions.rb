class User

  # Méthode pour passer l'utilisateur à un jour-programme
  # particulier
  #
  # +index_pday+ Passe l'user à ce jour-programme
  # +options+   Hash pour définir l'état des travaux
  #   :start_upto     Démarrer les travaux jusqu'à ce jour-programme
  #                   Si non défini, on prend :complete_upto
  #   :complete_upto  Marquer les travaux finis jusqu'à ce jour
  #                   Les démarrer au besoin
  #   :quiz           {Array} Liste de quiz à enregistrer. Chaque valeur doit
  #                   être un Hash définissant :
  #                     :pday       Le jour-programme du quiz programme (note : pas
  #                                 celui où il a été fait)
  #                     :awork_id   Le travail absolu de ce quiz.
  #                     :resultats  Les valeurs tirées de TEST_DATA_QUIZ pour les
  #                                 mettre dans la table résultats. Il faut
  #                                 renseigner :user_id et :created_at et les
  #                                 enregistrer dans la table 'resultats'
  #                                 de la base `boite-a-outils_quiz_unan`
  #                   On renseigne aussi :item_id du work correspondant au quiz
  #                   en mettant la valeur de la rangée enregistrée dans la
  #                   table 'resultats'
  #
  def set_pday_to index_pday, options = nil
    site.require_objet 'unan'
    created_at = NOW - index_pday * (24 * 3600)
    program.set(created_at: created_at, updated_at: created_at)
    program.current_pday= index_pday

    # Si des options sont définies
    if options != nil && !options.empty?

      # Démarrage de travaux et marquage finis
      # --------------------------------------
      demarre_ses_travaux   upto: (options[:start_upto] || options[:complete_upto])
      marque_travaux_finis  upto: options[:complete_upto]

      # Quiz
      # ----
      if options.key? :quiz
        options[:quiz].each do |dquiz|
          awork_id  = dquiz[:awork_id]
          pday      = dquiz[:pday]
          resultats = dquiz[:resultats]
          # On renseigne les données non renseignées
          resultats.merge!(
            user_id:    self.id,
            created_at: created_at + (pday + 1).days
          )
          # On enregistre le résultat dans la table
          res_id = site.dbm_table(:quiz_unan, 'resultats').insert(resultats)
          # On met l'item_id du travail à res_id
          tbl = site.dbm_table(:users_tables, "unan_works_#{self.id}")
          hwork = tbl.get(where: {abs_pday: pday, abs_work_id: awork_id})
          puts hwork.inspect
          tbl.update(hwork[:id], { item_id: res_id })
        end
      end
      # /fin s'il y a des quiz

    end
    # /s'il y avait des options

  end

  # Pour démarrer les travaux de l'utilisateur
  #
  # Ça se fait en deux temps :
  #   1. récupération des travaux à démarrer
  #   2. démarrage des travaux
  #
  # +what+
  #   SI
  #     {upto: <pday> }
  #     OU
  #     :all    Tous les travaux à démarrer, c'est-à-dire ceux
  #             des jours précédents et ceux du jour courant.
  #
  def demarre_ses_travaux what
    if what == :all
      what = {upto: self.program.current_pday}
    end

    upto_pday = what.delete(:upto)
    upto_pday != nil || raise('Il faut définir :upto')

    # Il faut mettre l'user en user courant
    User.current= self

    # La liste qui va contenir tous les triplets de données
    # nécessaires pour créer le travail ([user, id abs work, pday abs work])
    arr_data = Array.new

    # Démarrer tous les travaux avant le jour courant
    arr_data +=
      self.current_pday.aworks_unstarted.collect do |hwork|
        # puts "- #{hwork.inspect}"
        hwork[:pday] <= upto_pday
        [self, hwork[:awork_id], hwork[:pday]]
      end.compact

    # Démarrer tous les travaux du jour courant (si demandé)
    if upto_pday == self.program.current_pday
      arr_data +=
        self.current_pday.aworks_ofday.collect do |hwork|
          [self, hwork[:awork_id], hwork[:pday]]
        end
    end

    # Le module qui permet de créer un work, ce qui correspond
    # au démarrage du travail.
    require './objet/unan/lib/module/work/create.rb'

    # On démarre tous ces travaux
    arr_data.each do |dstart|
      # dstart = [self, awork_id, work_pday]
      Unan::Program::Work.send(:start_work, *dstart)
    end

    puts "Démarrage des travaux jusqu'au jour-programme #{upto_pday}"
  end

  # Marque fini les travaux jusqu'à un certain jour
  #
  # +options+
  #     NIL     Marque tous les travaux finis
  #     :all    Idem
  #     Hash contenant :
  #       upto:     Jusqu'à ce jour-programme
  #
  def marque_travaux_finis options = nil
    case options
    when NilClass, :all
      upto_pday = self.program.current_pday
    when :yesterday
      upto_pday = self.program.current_pday - 1
    when Hash
      upto_pday = options.delete(:upto)
    else
      raise 'Il faut définir le jour-programme pour marquer les travaux finis'
    end

    drequest = {colonnes: [:status, :abs_pday]}
    # drequest = {}
    start_program_time = NOW - self.program.current_pday.days
    self.table_works.select(drequest).each do |hwork|
      next if hwork[:abs_pday] > upto_pday
      wid = hwork[:id]
      fin = start_program_time + (hwork[:abs_pday] + 1).days
      self.table_works.update(wid, {status: 9, ended_at: fin, updated_at: fin})
    end
  end

end
