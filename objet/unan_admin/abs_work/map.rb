# encoding: UTF-8
raise_unless_admin

site.require_objet 'unan'
Unan.require_module 'abs_work'

class UnanAdmin
class Program
class AbsWork

  MAP_DAY_WIDTH   = 40   # Largeur en pixels de chaque jour sur la carte
  MAP_DAY_HEIGHT  = 20    # Hauteur
  MAP_WIDTH       = 365 * MAP_DAY_WIDTH


  class << self

    def init_map
      @zones ||= begin
        {
          tasks:  Hash.new,
          pages:  Hash.new,
          quiz:   Hash.new,
          forum:  Hash.new
        }
      end
    end

    # La hauteur de la carte des travaux, en fonction des
    # rangées qui ont dû être construites
    # Sert à définir le style css dans map.erb pour le div
    # de la map
    def map_height
      @map_height ||= (Unan::Program::AbsWork.first_row_last_zone + @zones[:forum].count) * (MAP_DAY_HEIGHT + 2)
    end

    # {Fixnum} Retourne une hauteur (un cran) libre où peut
    # être placé le travail sur la carte
    def free_top_zone_for left, width, type_id

      return 0 if @zones[type_id].empty?
      index_row = nil

      # Le départ et la fin de la nouvelle zone
      from, to = [left.freeze, (left + width - 1).freeze]

      # On va boucler sur toutes les zones déjà occupées pour
      # choisir un espace libre. S'il n'existe pas, on ajoute
      # une nouvelle rangée
      @zones[type_id].each do |irow, troncons|

        # Si la nouvelle zone peut être placée avant le
        # premier tronçon, on prend cette ligne
        premier_troncon = troncons.first
        return irow if premier_troncon && to < premier_troncon[:from]

        last_to = nil
        troncons.each do |troncon|
          # Si on trouve un troncon vide, on peut le renvoyer
          if last_to != nil && last_to < from && troncon[:from] > to
            return irow
          end
          last_to = troncon[:to].to_i
        end

        # Si le from du nouveau tronçon est supérieur au dernier
        # to traité, on peut ajouter le nouveau tronçon ici
        return irow if from > last_to && to > last_to

      end

      # Si on passe par ici, c'est qu'aucun espace n'a été trouvé
      # On doit ajouter une rangée
      return @zones[type_id].keys.last + 1
    end

    # Mémorise la zone du travail qui commence à left et
    # fait une largeur de width à la rangée irow de la
    # carte. Cette zone ne pourra plus être occupée par un
    # travail suivant.
    def memorize_zone left, width, irow, type_id
      @zones[type_id].merge!( irow => Array::new ) unless @zones[type_id].has_key?(irow)
      # Liste des tronçons occupés, qui ressemblent à
      # [{:from, :to}, {:from, :to}....]
      troncons = @zones[type_id][irow]

      from  = left
      to    = left + width - 1
      added = {from: from, to: to}

      # On cherche si la zone peut être ajoutée avant le
      # premier troncon. Si c'est le cas, on l'ajoute et
      # on s'en retourne directement
      if troncons.first && to < troncons.first[:from]
        @zones[type_id][irow] = [added] + troncons
        return
      end
      # On cherche si on peut allonger un tronçons existant
      troncons_finaux = Array::new
      troncon_added   = false
      troncons.each do |troncon|

        unless troncon_added
          if troncon[:from] > to
            troncons_finaux << {from: from, to: to}
            troncon_added = true
          elsif troncon[:to] + MAP_DAY_WIDTH >= from
            troncon[:to] = to # On allonge le tronçon
            troncon_added = true
          end
        end

        troncons_finaux << troncon

      end
      # Si le tronçon n'a pas pu être ajouté (<= quand à la fin)
      troncons << {from: from, to: to} unless troncon_added

      @zones[type_id][irow] = troncons

    end


  end # << self


end # /AbsWork
end # /Program
end # /Unan


# Extension de Unan::Program::AbsWork
class Unan
class Program
class AbsWork

  # Chaque type de travail (tâche, page de cours, quiz, etc.) est mis
  # dans une rangée différente. Cette table indique le bord haut de
  # chaque rangée. On pourra l'augmenter s'il le faut.
  # Pour le moment, permet de superposer 5 éléments de chaque type,
  # ce qui devrait suffire.
  FIRST_ROW_BY_TYPES = {
    tasks:  0,
    pages:  8,
    quiz:   16,
    forum:  24
  }

  def self.first_row_last_zone
    Unan::Program::AbsWork::FIRST_ROW_BY_TYPES[:forum]
  end

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # {StringHTML} Code HTML du travail sur la carte
  def in_map jour_depart
    @jour_depart = jour_depart
    get_all # pour charger toutes les données BdD d'un coup
    top   = (free_row + FIRST_ROW_BY_TYPES[type_id]) * (UnanAdmin::Program::AbsWork::MAP_DAY_HEIGHT + 2)
    memorize_zone
    # Le code HTML retourné, qui contient le span pour le titre
    # sur la map et le code (caché) pour les informations complètes
    # sur le travail.
    displayed_infos.in_div(id: "awork-#{id}-#{jour_depart}", class:'work', 'data-id' => "#{id}-#{jour_depart}", style:"top:#{top}px;left:#{left}px;width:#{width}px")
  end

  def type_id
    @type_id ||= Unan::Program::AbsWork::TYPES[type_w][:id_list]
  end

  # On utilise un des users qui suit le programme pour pouvoir déserber
  # les pages. Si aucun user ne suit le programme, on en crée un
  def user_unan
    @user_unan ||= begin
      hprog = site.dbm_table(:unan, 'programs').select(colonnes: [:auteur_id], order: 'created_at desc', limit: 1).first
      User.new( hprog[:auteur_id] )
    end
  end

  def bind; binding() end
  def user ; user_unan end

  def displayed_infos
    @displayed_infos ||= begin
      titre.in_span(class:'titre') +
      (
        (
          'x'.in_a(class:'btn_close', onclick: "$.proxy(MapWorks,'close_work','#{id}-#{jour_depart}')()")
        ).in_div +
        work_id_with_liens +
        work_item_id_with_liens +
        ("Type : ".in_span(class:'libelle') + "#{human_type_w}").in_div +
        "P-Days #{jour_depart} à #{jour_fin}".in_div +
        div_pages_cours +
        div_work_exemples +
        div_travail
      ).in_div(class: 'details')
      # ("Résultat : ".in_span(class:'libelle') + "#{resultat}").in_div(class:'italic')
    end
  end

  def work_id_with_liens
    lien_editer   = 'éditer'.in_a(href: "abs_work/#{id}/edit?in=unan_admin", target: :new)
    lien_afficher = 'afficher'.in_a(href: "abs_work/#{id}/show?in=unan", target: :new)
    "WORK ##{id} (#{lien_editer}#{lien_afficher})".in_span(class:'id')
  end
  def work_item_id_with_liens
    item_id != nil || (return '')
    "ITEM_ID ##{item_id}".in_span(class: 'item_id')
  end

  def div_travail
    ("Travail : ".in_span(class:'libelle') + "#{travail.deserb(self.bind)}").in_div(class:'italic')
  end

  def div_work_exemples
    has_work_exemples? || (return '')
    mark_has_work_exemple = ''.in_span(class:'markex')
    eids = self.exemples_ids
    eids.instance_of?(Array) || eids = eids.as_list_num_with_spaces
    (
      mark_has_work_exemple +
      "Exemples associés (#{eids.count}) : " +
      eids.collect do |eid|
        lien_work_exemple(eid)
      end.join(', ')
    ).in_div(class: 'dv_pgc')
  end
  def lien_work_exemple eid
    "##{eid} (" +
    'voir'.in_a(href: "exemple/#{eid}/show?in=unan", target: :new) +
    'edit'.in_a(href: "exemple/#{eid}/edit?in=unan_admin", target: :new) +
    ')'
  end
  # Retourne true si le travail contient des pages de cours
  def has_work_exemples?
    @has_work_exemples === nil && @has_work_exemples = !exemples_ids.empty?
    @has_work_exemples
  end

  # Si le travail définit des pages cours, on les indique avec un lien
  # pour les afficher.
  def div_pages_cours
    has_pages_cours? || (return '')
    # La marque pour indiquer que le travail est associé à des
    # pages de cours (qui ne seront pas affichées en tant que travaux puisque
    # seuls les travaux qui consistent en la lecture de page de cours sont
    # affichés.)
    mark_has_pages_cours = ''.in_span(class:'markpg')
    pids = self.pages_cours_ids
    pids.instance_of?(Array) || pids = pids.as_list_num_with_spaces
    (
      mark_has_pages_cours +
      "Pages de cours associées (#{pids.count}) : " +
      pids.collect do |pid|
        lien_page_cours(pid)
      end.join(', ')
    ).in_div(class: 'dv_pgc')
  end
  def lien_page_cours pcid
    "##{pcid} (" +
    'voir'.in_a(href: "page_cours/#{pcid}/show?in=unan", target: :new) +
    'edit'.in_a(href: "page_cours/#{pcid}/edit?in=unan_admin", target: :new) +
    ')'
  end

  # Retourne true si le travail contient des pages de cours
  def has_pages_cours?
    @has_pages_cours === nil && @has_pages_cours = !pages_cours_ids.empty?
    @has_pages_cours
  end

  # Le jour de départ et de fin du travail.
  # Noter que maintenant, ce jour dépend du P-Day auquel appartient le
  # travail, qui n'est connu que du P-Day. En effet, un même travail
  # peut appartenir à plusieurs P-Day. Ce jour_depart est fixé par
  # argument à la méthode `in_map` ci-dessus.
  # En revanche, la durée est propre au travail, même si on pourrait
  # imaginer qu'elle soit différente en fonction du P-Day. Peut-être
  # est-ce une donnée qui pourrait être précisée dans le "work" propre
  # au P-Day… Mais comment le définir ?
  def jour_depart ; @jour_depart end
  def jour_fin    ; @jour_fin ||= jour_depart + duree - 1 end

  def left
    @left ||= (jour_depart - 1) * UnanAdmin::Program::AbsWork::MAP_DAY_WIDTH
  end
  def width
    @width ||= (duree * UnanAdmin::Program::AbsWork::MAP_DAY_WIDTH) - 6
  end
  def free_row
    @free_row ||= UnanAdmin::Program::AbsWork.free_top_zone_for(left, width, type_id)
  end

  def memorize_zone
    UnanAdmin::Program::AbsWork.memorize_zone(left, width, free_row, type_id)
  end

end # /AbsWork
end # /Program
end # /Unan

UnanAdmin::Program::AbsWork.init_map
