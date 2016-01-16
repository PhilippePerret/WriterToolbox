=begin

Test de la procédure de démarrage d'un jour-programme

Principe
--------

=end
describe 'Démarrage d’un jour-programme' do

  before(:all) do
    @user     = create_user( unanunscript:true )
    @program  = @user.program
    expect(@program).to be_instance_of Unan::Program
  end
  let(:user)    { @user }
  let(:program) { @program }

  describe 'program#start_pday' do
    it 'répond' do
      expect(program).to respond_to :start_pday
    end
    context 'sans argument' do
      it 'produit une erreur' do
        expect{program.start_pday}.to raise_error ArgumentError
      end
    end
    context 'avec un nombre correct' do
      it 'ne produit pas d’erreur' do
        expect{program.start_pday 12}.not_to raise_error
      end
    end
  end

  describe 'pday#start' do

  end

end
