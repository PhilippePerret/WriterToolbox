describe 'Méthodes Unan::Program::works' do
  before(:all) do
    site.require_objet 'unan'
    @program = get_any_program
  end
  let(:program) { @program }


  it 'répond' do
    expect(program).to respond_to :works
  end
  it 'retourne une liste' do
    expect(program.works).to be_instance_of Array
  end
  it 'retourne une liste de Hash de données des travaux' do
    res = program.works
    res.each do |w|
      expect(w).to be_instance_of Hash
    end
  end

end
