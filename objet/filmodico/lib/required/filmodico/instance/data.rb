# encoding: UTF-8
class Filmodico

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def film_id     ; @film_id      ||= get(:film_id)               end
  def titre       ; @titre        ||= get(:titre).force_encoding('utf-8') end
  def titre_fr    ; @titre_fr     ||= get(:titre_fr).nil_if_empty end
  def resume      ; @resume       ||= get(:resume)                end
  def annee       ; @annee        ||= get(:annee)                 end
  def duree       ; @duree        ||= get(:duree)                 end
  def realisateur ; @realisateur  ||= dejson_people(get(:realisateur))  end
  def producteurs ; @producteurs  ||= dejson_people(get(:producteurs))  end
  def auteurs     ; @auteurs      ||= dejson_people(get(:auteurs))      end
  def acteurs     ; @acteurs      ||= dejson_people(get(:acteurs))      end
  def musique     ; @musique      ||= dejson_people(get(:musique))      end
  def links       ; @links        ||= get(:links)                 end
  def pays
    @pays ||= (get(:pays)||"").split(' ')
  end

  # On doit surclasser la méthode get_all pour traiter les
  # valeurs spéciales.
  def get_all
    super
    @realisateur  = dejson_people(@realisateur)
    @producteurs  = dejson_people(@producteurs)
    @auteurs      = dejson_people(@auteurs)
    @acteurs      = dejson_people(@acteurs)
    @musique      = dejson_people(@musique)
    @pays = (@pays || "").split(' ')
    @titre = @titre.force_encoding('utf-8')
  end
  def dejson_people raw
    return "" if raw.nil?
    raw = JSON.parse(raw)
    if raw.first.instance_of?(String)
      raw =
        raw.collect do |el|
          JSON.parse(el)#.to_sym
        end
    end
    return raw.to_sym
  end

end
