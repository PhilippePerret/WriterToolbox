site.require_objet 'unan'

describe 'Méthodes de données d’une instance Unan::Program::PageCours' do
  before(:all) do
    @pagecours = page_cours(1)
  end
  let(:pagecours) { @pagecours }

  describe '#fullpath' do
    it 'répond' do
      expect(pagecours).to respond_to :fullpath
    end
    it 'retourne une instance SuperFile' do
      expect(pagecours.fullpath).to be_instance_of SuperFile
    end
    it 'retourne le bon fullpath' do
      expect(pagecours.fullpath.to_s).to eq "./data/unan/pages_cours/program/test.erb"
    end
  end

end
