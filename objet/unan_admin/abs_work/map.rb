# encoding: UTF-8
raise_unless_admin
site.require_objet 'unan'
class UnanAdmin
class Program
class AbsWork

  MAP_DAY_WIDTH   = 40   # Largeur en pixels de chaque jour sur la carte
  MAP_DAY_HEIGHT  = 20    # Hauteur
  MAP_WIDTH       = 365 * MAP_DAY_WIDTH

  class << self

    def init_map
      @zones ||= Hash::new
    end

    # La hauteur de la carte des travaux, en fonction des
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


end # /AbsWork
end # /Program
end # /Unan

# Extension de Unan::Program::AbsWork
class Unan
class Program
class AbsWork
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # {StringHTML} Code HTML du travail sur la carte
  def in_map jour_depart
    @jour_depart = jour_depart
    get_all # pour charger toutes les données d'un coup
    top   = free_row * (UnanAdmin::Program::AbsWork::MAP_DAY_HEIGHT + 2)
    memorize_zone
    # Le code HTML retourné
    displayed_infos.in_a(href:"abs_work/#{id}/edit?in=unan_admin", target:"_new").in_div(class:'work', style:"top:#{top}px;left:#{left}px;width:#{width}px")
  end

  def displayed_infos
    @displayed_infos ||= begin
      (
        "#{titre}".in_span(class:'bold') + " [work ##{id}]".in_span(class:'id') +
        ("Type W : ".in_span(class:'libelle') + "#{human_type_w}").in_div +
        "P-Days #{jour_depart} à #{jour_fin}".in_div +
        ("Travail : ".in_span(class:'libelle') + "#{travail}").in_div(class:'italic') +
        ("Résultat : ".in_span(class:'libelle') + "#{resultat}").in_div(class:'italic')
      ).in_div(class:'infos')
    end
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
    @width ||= duree * UnanAdmin::Program::AbsWork::MAP_DAY_WIDTH
  end
  def free_row
    @free_row ||= UnanAdmin::Program::AbsWork::free_top_zone_for(left, width)
  end

  def memorize_zone
    UnanAdmin::Program::AbsWork::memorize_zone(left, width, free_row)
  end

end # /AbsWork
end # /Program
end # /Unan

UnanAdmin::Program::AbsWork::init_map
