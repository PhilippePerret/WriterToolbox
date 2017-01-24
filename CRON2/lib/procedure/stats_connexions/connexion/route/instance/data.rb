# encoding: UTF-8
=begin
  Instance Connexions::Connexion::Route
  -------------------------------------
  Data
=end
class Connexions
class Connexion
class Route

  # {Connexions::Connexion} Connexion à cette route
  attr_reader :connexion

  # Données de la route décomposée
  attr_reader :objet, :objet_id, :method, :context


  def route
    @route ||= connexion.route
  end

  def duree_reelle
    @duree_reelle ||= begin
      connexion.duree
    end
  end

  def add_duree_reelle duration
    duree_reelle
    @duree_reelle += duration
  end

  # Ensemble auquel appartient la route, par exemple :
  # 'Narration', ou 'Scénodico', etc.
  def ensemble
    @ensemble ||= begin
      decompose_route
      case context
      when 'cnarration' then :narration
      when 'unan'       then :unan
      else
        case objet
        when 'page'       then :narration
        when 'scenodico'  then :scenodico
        when 'filmodico'  then :filmodico
        when 'admin'      then :admin
        when 'citation'   then :citation
        when 'tool'       then :tool
        end
      end
    end
  end

  def decompose_route
    reg = /([a-zA-Z_]+)(?:\/([0-9]+))?\/([a-zA-Z_]+)(?:\?in=([a-zA-Z_]+))?/
    # tout, objet, objet_id, method, context = param(:route).match(reg).to_a
    tout, @objet, @objet_id, @method, @context = route.match(reg).to_a
  end

end #/Route
end #/Connexion
end #/Connexions
