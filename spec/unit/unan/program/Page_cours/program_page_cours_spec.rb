=begin

Test de la méthode générale

=end
require_folder './objet/unan/lib/required'

describe 'UnAn::Program #page_cours' do
  before(:all) do
    @program = Unan::Program::new(0)
  end
  let(:program) { @program }
  it 'répond' do
    expect(program).to respond_to :page_cours
  end

  context 'sans argument' do
    it 'produit une erreur fatale' do
      expect{program.page_cours}.to raise_error ArgumentError
    end
  end
  context 'avec un argument invalide' do
    it 'produit une erreur d’argument' do
      [true, Unan, 12, {un: "hash"}, [1, Array]].each do |badtyp|
        expect{program.page_cours badtyp}.to raise_error ArgumentError
      end
    end
  end
  context 'avec un argument valide (handler) mais pointeur introuvable' do
    it 'produit une erreur d’argument' do
      expect{program.page_cours :bad_pointeur}.to raise_error ArgumentError, "Page de cours introuvable (:bad_pointeur)"
    end
  end
  context 'avec un pointeur valide en argument' do
    it 'retourne une instance Unan::Program::PageCours' do
      res = program.page_cours(:introduction_uaus)
      expect(res).to be_instance_of Unan::Program::PageCours
      expect(res.titre).to eq "Introduction au programme “Un An Un Script”"
    end
  end
end
