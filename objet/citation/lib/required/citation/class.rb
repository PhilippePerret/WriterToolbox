# encoding: UTF-8
class Citation

  extend MethodesMainObjets

class << self

  def current
    @current ||= new(site.current_route.objet_id)
  end

  def titre
    @titre ||= "Citations d'auteurs"
  end

  def data_onglets
    @data_onglets ||= {
      'Au hasard' => 'citation/round'
    }
  end

end #/ <<self
end #/ Citation
