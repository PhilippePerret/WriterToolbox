describe 'Data de page de cours' do
  before(:all) do
    @start_time = Time.now.to_i
    site.require_objet 'unan'
    Unan::require_module 'page_cours'

    @auteur       = get_any_user(:with_program => true)
    @pagecours    = Unan::Program::PageCours::new(1)
    @titre = @pagecours.get(:titre)
  end

  let(:start_time) { @start_time }
  let(:auteur) { @auteur }
  let(:pagecours) { @pagecours }

  #titre
  describe '#titre' do
    it 'répond' do
      expect(pagecours).to respond_to :titre
    end
    it 'retourne le titre' do
      expect(pagecours.titre).to eq @titre
    end
  end


end
