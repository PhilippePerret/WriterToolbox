describe 'Méthodes d’état d’un jour-programme absolu' do
  before(:all) do
    site.require_objet 'unan'
    liste_ids_abs_pdays = Unan::table_absolute_pdays.select(colonnes:[:id]).collect{|h|h[:id]}
    inexistant_id = nil
    existant_id   = nil
    (1..365).each do |checked_id|
      if ( liste_ids_abs_pdays.include? checked_id )
        existant_id = checked_id.freeze
      else
        inexistant_id = checked_id.freeze
      end
    end
    @apd_existant = Unan::Program::AbsPDay::new(existant_id)
    @apd_inexistant = Unan::Program::AbsPDay::new(inexistant_id)
  end
  let(:apd) { @apd_existant }
  let(:apd_existant) { @apd_existant }
  let(:apd_inexistant) { @apd_inexistant }
  describe 'AbsPDay#exist?' do
    it 'répond' do
      expect(apd).to respond_to :exist?
    end
    context 'avec un jour-programme existant' do
      it 'retourne true' do
        expect(apd_existant).to be_exist
      end
    end
    context 'avec un jour-programme inexistant' do
      it 'retourne false' do
        expect(apd_inexistant).not_to be_exist
      end
    end
  end
end
