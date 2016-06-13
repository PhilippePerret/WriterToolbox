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
      'Recherche' => 'citation/search',
      'Au hasard' => 'citation/round'
    }
  end

  def table
    @table ||= site.db.create_table_if_needed('site_cold', 'citations')
  end

end #/ <<self
end #/ Citation
