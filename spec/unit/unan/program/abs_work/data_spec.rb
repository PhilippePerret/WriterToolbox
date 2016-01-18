describe 'Méthodes de données des AbsWork(s)' do
  before(:all) do
    site.require_objet 'unan'
    work_ids    = Unan::Program::AbsWork::table.select(colonnes:[:id]).keys
    @work_id    = work_ids.shuffle.shuffle.first.freeze
    @data_work  = Unan::Program::AbsWork::table.get(@work_id)
    @work       = Unan::Program::AbsWork::new(@work_id)
  end

  let(:work) { @work }
  describe 'AbsWork#titre' do
    it 'répond' do
      expect(work).to respond_to :titre
    end
    it 'retourne le bon titre' do
      expect(work.titre).not_to eq nil
      expect(work.titre).not_to eq ""
      expect(work.titre).to eq @data_work[:titre]
    end
  end
end
