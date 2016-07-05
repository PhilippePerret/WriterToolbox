# encoding: UTF-8
=begin

  Module qui construit une nouvelle page narration.

  - Vérifie au préalable que la page narration ne soit pas
    déjà utilisée
  - Créer

=end
class Console
  def new_page_narration args
    npage = NPage.new(args)
    npage.page_unused? || raise('La page narration %{page_id} est déjà utilisée (%{errors}).' % args.merge(errors: npage.errors))
    npage.create
    flash "Page narration insérée dans le programme."
  rescue Exception => e
    debug e
    error e.message
  end

  class NPage

    # {Fixnum} ID de la page narration
    attr_reader :id

    # {Fixnum|Nil} Jour programme, s'il est défini
    attr_reader :pday

    # Liste des erreurs rencontrées, qui pourront
    # être lues en utilisant <instance>.errors
    attr_reader :errors

    # L'ID de la page de cours programme qui a
    # été construite pour la page Narration
    attr_reader :page_cours_id

    # L'ID du travail absolu qui a été construit
    # pour la page
    attr_reader :abs_work_id

    def initialize args
      @id   = args[:page_id].to_i
      @pday = args[:pday] # peut être nil
      @pday == nil || @pday = @pday.to_i
    end

    # = main =
    #
    # Méthode principale créant la page
    #
    def create
      # Création de la page de cours UNAN qui doit être créée
      # Pour recevoir la page Narration. C'est son ID qui sera
      # enregistré dans le work absolu
      create_page_cours || return

      # Création du travail absolu
      create_absolute_work || return
      # Lien pour éditer tout de suite le travail
      out = ['Il faut régler le travail absolu (nombre de jours et sujet cible au moins)'.in_span(class: 'red')]
      out << 'Finaliser le travail contenant la page'.in_a(href: "abs_work/#{abs_work_id}/edit?in=unan_admin", target: :new)

      # Création du jour-programm si défini et si nécessaire
      pday == nil || begin
        create_jour_programme_if_needed
        'Jour-programme (pour classer le travail)'.in_a(href: "abs_pday/#{pday}/edit?in=unan_admin", target: :new)
      end
      # Sortie à afficher
      console.output out
    rescue Exception => e
      debug e
      error "Problème en créant la page."
    end

    # Création de la page de cours qui recevra la page
    # narration
    def create_page_cours
      data_page = {
        path:         nil,
        handler:      nil,
        titre:        nil,
        description:  nil,
        narration_id: id,
        type:         'N',
        options:      nil,
        created_at:   NOW,
        updated_at:   NOW
      }
      @page_cours_id = table_pages_cours.insert(data_page)
    rescue Exception => e
      debug e
      error e.message
      false
    else
      true
    end
    # Création du travail absolu
    def create_absolute_work
      titre = '%s<span class="tiny"> (collection Narration)</span>' % titre_page
      data_work = {
        titre:            titre,
        type_w:           20,
        type:             '004200',
        type_resultat:    '810',
        duree:            4,
        travail:          'Page de cours à lire.',
        parent:           nil,
        prev_work:        nil,
        resultat:         'Une page de cours lue.',
        item_id:          page_cours_id,
        exemples:         nil,
        pages_cours_ids:  nil,
        points:           100,
        updated_at:       NOW.to_i,
        created_at:       NOW.to_i
      }
      @abs_work_id = table_works.insert(data_work)
    rescue Exception => e
      debug e
      error e.message
      false
    else
      true
    end

    # Création du jour programme si c'est nécessaire
    # Noter qu'on ne passe ici que si un jour-programme a été
    # précisé, donc il est inutile de le vérifier.
    def create_jour_programme_if_needed
      if table_pdays.count(where: {id: pday}) == 0
        create_jour_programme
      else
        # Il faut ajouter le travail aux travaux que le jour
        # contient peut-être déjà
        works = table_pdays.get( pday, colonnes: [:works])[:works]
        works = ((works || '').split(' ') << abs_work_id).join(' ')
        table_pdays.update(pday, { works: works })
      end
    end

    # Création du jour-programme.
    def create_jour_programme
      data_pday = {
        id:             pday,
        titre:          "#{pday}<sup>e</sup> jour-programme",
        description:    nil,
        works:          "#{abs_work_id}",
        minimum_points: nil,
        created_at:     NOW,
        updated_at:     NOW
      }
      table_pdays.insert( data_pday )
    end

    # {String} Le titre de la page dans la collection
    # narration, pour le titre du travail
    def titre_page
      @titre_page ||= begin
        site.dbm_table(:cnarration, 'narration').get(id, colonnes: [:titre])[:titre]
      end
    end

    # Raccourcis
    def table_pages_cours
      @table_pages_cours ||= Unan.table_pages_cours
    end
    def table_works
      @table_works ||= Unan.table_absolute_works
    end
    def table_pdays
      @table_pdays ||= Unan.table_absolute_pdays
    end

    def id_string
      @id_string ||= id.to_s
    end

    # Retourne true si la page narration n'est pas déjà
    # utilisée
    def page_unused?
      if table_works.count( where: {item_id: id} ) == 0
        return true
      else
        wdata = table_works.get( where: {item_id: id} )
        debug "wdata: #{wdata.inspect}"
        wid = wdata[:id].to_s
        jdata = []
        table_pdays.select( where: "works LIKE '%#{wdata[:id]}%'").each do |ddata|
          works = ddata[:works].split(' ')
          works.include?( wid ) || next
          jdata << ddata[:id]
        end
        # Construction des liens envoyant aux travaux utilisant
        # la page
        output = []
        output << 'Pour voir les jours et les travaux'.in_div(class: 'underline')
        jdata.each do |pid|
          output << "Jour-Programme ##{pid} (édition)".in_a(href: "abs_pday/#{pid}/edit?in=unan_admin", target: :new)
        end
        output << "Travail absolu ##{wid} (édition)".in_a(href: "abs_work/#{wid}/edit?in=unan_admin", target: :new)
        @errors =
          if jdata.count == 1
            "sur le jour #{jdata.first}"
          else
            "sur les jours #{jdata.pretty_join}"
          end
          console.add_message output
        false
      end
    end
  end
end
