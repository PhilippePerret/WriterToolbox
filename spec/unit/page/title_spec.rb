describe 'page#title' do
  before(:all) do
    @titre_site_entier = "La Boite à Outils de l'Auteur"
    @explicite_title   = "Un titre explicite"
    execute_route("")
  end
  it 'répond' do
    expect(page).to respond_to :title
  end
  context 'sur la home du site' do
    it 'retourne le nom entier' do
      execute_route(nil)
      expect(page.title).to eq @titre_site_entier.upcase
    end
  end
end
