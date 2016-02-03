# encoding: UTF-8
raise_unless_admin
class UnanAdmin
class Program
class AbsPDay

  MAP_DAY_WIDTH   = 40
  MAP_DAY_HEIGHT  = 20
  MAP_WIDTH       = 365 * MAP_DAY_WIDTH


  class << self

    def init_map
      @zones ||= Hash::new
    end

    # La hauteur de la carte des pdays, en fonction des
    # rangées qui ont dû être construites
    # Sert à définir le style css dans map.erb pour le div
    # de la map
    def map_height
      @map_height ||= @zones.count * (MAP_DAY_HEIGHT + 2)
    end

    # {Fixnum} Retourne une hauteur (un cran) libre où peut
    # être placé le travail sur la carte
    def free_top_zone_for left, width

      return 0 if @zones.empty?
      index_row = nil

      # Le départ et la fin de la nouvelle zone
      from, to = [left.freeze, (left + width - 1).freeze]

      # On va boucler sur toutes les zones déjà occupées pour
      # choisir un espace libre. S'il n'existe pas, on ajoute
      # une nouvelle rangée
      @zones.each do |irow, troncons|

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
      return @zones.keys.last + 1
    end

    # Mémorise la zone du travail qui commence à left et
    # fait une largeur de width à la rangée irow de la
    # carte. Cette zone ne pourra plus être occupée par un
    # travail suivant.
    def memorize_zone left, width, irow
      @zones.merge!( irow => Array::new ) unless @zones.has_key?(irow)
      # Liste des tronçons occupés, qui ressemblent à
      # [{:from, :to}, {:from, :to}....]
      troncons = @zones[irow]

      from  = left
      to    = left + width - 1
      added = {from: from, to: to}

      # On cherche si la zone peut être ajoutée avant le
      # premier troncon. Si c'est le cas, on l'ajoute et
      # on s'en retourne directement
      if troncons.first && to < troncons.first[:from]
        @zones[irow] = [added] + troncons
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

      @zones[irow] = troncons

    end

  end # << self


end #/AbsPDay
end #/Program
end #/UnanAdmin

# Extension de Unan::Program::AbsPDay
class Unan
class Program
class AbsPDay
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # {StringHTML} Code HTML du travail sur la carte
  def in_map
    get_all # pour charger toutes les données d'un coup
    top   = free_row * (UnanAdmin::Program::AbsPDay::MAP_DAY_HEIGHT + 2)
    memorize_zone
    # Le code HTML retourné
    displayed_infos.in_a(href:"abs_pday/#{id}/edit?in=unan_admin", target:"_new", 'data-id' => id.to_s, onclick:"$.proxy(PDays,'onclick',this)()").in_div(class:'pday', id:"pday-#{id}", style:"top:#{top}px;left:#{left}px;width:#{width}px")
  end

  def displayed_infos
    @displayed_infos ||= begin
      (
        "PD#{id} / #{titre}"  +
        "P-Day #{id}".in_div +
        ("Travaux : ".in_span(class:'libelle') + "#{travaux}").   in_div(class:'italic')
      ).in_div(class:'infos')
    end
  end

  def travaux
    @travaux ||= begin
      works_ids.collect do |wid|
        aw = Unan::Program::AbsWork::new(wid.to_i)
        "Travail ##{wid} : #{aw.titre}".in_div
      end.join
    end
  end
  def left
    @left ||= (id - 1) * UnanAdmin::Program::AbsPDay::MAP_DAY_WIDTH
  end
  def width
    @width ||= 1 * UnanAdmin::Program::AbsPDay::MAP_DAY_WIDTH
  end
  def free_row
    @free_row ||= UnanAdmin::Program::AbsPDay::free_top_zone_for(left, width)
  end

  def memorize_zone
    UnanAdmin::Program::AbsPDay::memorize_zone(left, width, free_row)
  end

end # /AbsPDay
end # /Program
end # /Unan

UnanAdmin::Program::AbsPDay::init_map
