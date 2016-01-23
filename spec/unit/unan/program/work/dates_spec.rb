describe 'Gestion des dates pour les works' do
  before(:all) do
    degel 'benoit-just-signup'
    site.require_objet 'unan'
    @program  = get_any_program
    @work     = @program.work(1)

  end

  let(:program) { @program }
  let(:work) { @work }

  describe '#expected_end' do
    before(:all) do

    end
    it { expect(work).to respond_to :expected_end }
    it 'retourne la date de fin attendue' do
      expect(work.expected_end).to eq ( work.created_at + work.duree_relative )
    end
  end
end
