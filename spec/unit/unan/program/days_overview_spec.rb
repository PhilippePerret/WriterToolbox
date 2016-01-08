=begin
Test de la propriété `days_overview` d'un programme UN AN UN SCRIPT
=end

require_folder './objet/unan/lib/required'

describe 'Test de la propriété `days_overview` d’un programme' do

  before(:all) do
    @program = Unan::Program::new(0)
  end

  before(:each) do
    # On stubbe les méthodes get et set du programme pour ne pas
    # agir avec la base de donnée
    allow_any_instance_of(Unan::Program).to receive(:set){|sujet, hdata| "Je set #{hdata.inspect}"}
    allow_any_instance_of(Unan::Program).to receive(:get) do |sujet, vol|
      "Je get #{vol.inspect}"
    end
  end
  let(:program) { @program }


  # Définir la valeur de days_overview
  def set_to value
    daysover = Unan::Program::DaysOverview::new(@program)
    daysover.instance_variable_set('@value', value)
    @program.instance_variable_set('@days_overview', daysover)
  end

  describe 'Unan::Program properties & methods' do
    # Pour s'assure que rien ne sera touché
    describe 'essaie de get' do
      it 'retourne le texte stubbé' do
        expect(program.get('une valeur')).to eq "Je get \"une valeur\""
      end
    end
    # Pour s'assure que rien ne sera touché
    describe 'essaie de set' do
      it 'fait semblant de définir les valeurs' do
        expect(program.set({un:"Hash"})).to eq "Je set {:un=>\"Hash\"}"
      end
    end

    # #days_overview (noter le pluriel)
    describe '#days_overview' do
      it 'répond à days_overview' do
        expect(program).to respond_to :days_overview
      end
      it 'retourne la bonne valeur' do
        set_to "pourvoir"
        expect(program.days_overview.value).to eq "pourvoir"
      end
    end

    # #day_overview (noter le singulier)
    describe '#day_overview' do
      it 'répond à day_overview' do
        expect(program).to respond_to :day_overview
      end
      it 'retourne la valeur du jour demandé' do
        set_to "00vv09h4"
        days = {
          1 => 0, 2 => 1023, 3 => 9, 4 => 548
        }.each do |iday, valday|
          d = program.day_overview(iday)
          expect(d).to be_instance_of Unan::Program::DaysOverview::Day
          expect(d.value).to eq valday
        end
      end
    end

  end

  describe 'les méthodes pour modifier les bits des jours' do
    # Par exemple :
    # add_bit_fin
    # remove_bit_mail_deb
  end

  describe 'Les méthodes pour tester les jours-programme' do

    # par exemple :
    # mail_debut_sent?
    # start_confirmed_by_user?
  end
end
