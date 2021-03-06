# encoding: UTF-8
class Citation

  extend MethodesMainObjet

class << self

  def current
    @current ||= new(site.current_route.objet_id)
  end

  def titre
    @titre ||= "Citations d'auteurs"
  end

  def data_onglets
    @data_onglets ||= begin
      h = {
        'Recherche' => 'citation/search',
        'Au hasard' => 'citation/round'
      }
      user.admin? && h.merge!('[Administration]' => 'citation/admin')
      h
    end
  end

  def table_citations
    @table_citations ||= site.dbm_table(:biblio, 'citations')
  end
  alias :table :table_citations

end #/ <<self
end #/ Citation
