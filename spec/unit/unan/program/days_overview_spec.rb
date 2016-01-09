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
    @program.instance_variable_set('@all_days_overview', Array::new)
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
    before(:all) do
      set_to "vv00"
      @jour = @program.day_overview(2)
    end
    let(:jour) { @jour }
    describe 'pour le bit B_FIN (512)' do
      it 'répond à add_bit_fin' do
        expect(jour).to respond_to :add_bit_fin
      end
      it 'répond à remove_bit_fin' do
        expect(jour).to respond_to :remove_bit_fin
      end
      it 'permette d’ajouter et de retirer le bit' do
        expect(jour.value).to eq 0
        jour.add_bit_fin
        expect(jour.value).to eq 512
        jour.remove_bit_fin
        expect(jour.value).to eq 0
      end
    end
    describe 'pour le bit B_FORC_FIN (256)' do
      it 'répond à add_bit_forc_fin' do
        expect(jour).to respond_to :add_bit_forc_fin
      end
      it 'répond à remove_bit_forc_fin' do
        expect(jour).to respond_to :remove_bit_forc_fin
      end
      it 'permette d’ajouter et de retirer le bit' do
        expect(jour.value).to eq 0
        jour.add_bit_forc_fin
        expect(jour.value).to eq 256
        jour.remove_bit_forc_fin
        expect(jour.value).to eq 0
      end
    end
    describe 'pour le bit B_MAIL_FIN (128)' do
      it 'répond à add_bit_mail_fin' do
        expect(jour).to respond_to :add_bit_mail_fin
      end
      it 'répond à remove_bit_mail_fin' do
        expect(jour).to respond_to :remove_bit_mail_fin
      end
      it 'permettent d’ajouter et de retirer le bit de mail de fin' do
        expect(jour.value).to eq 0
        jour.add_bit_mail_fin
        expect(jour.value).to eq 128
        jour.remove_bit_mail_fin
        expect(jour.value).to eq 0
      end
    end
    # (64)
    # (32)
    # (16)
    # (8)
    describe 'pour le bit B_CONF_DEB(4)' do
      it 'répond à add_bit_conf_deb' do
        expect(jour).to respond_to :add_bit_conf_deb
      end
      it 'répond à remove_bit_conf_deb' do
        expect(jour).to respond_to :remove_bit_conf_deb
      end
      it 'permettent d’ajouter et de retirer le bit' do
        expect(jour.value).to eq 0
        jour.add_bit_conf_deb
        expect(jour.value).to eq 4
        jour.remove_bit_conf_deb
        expect(jour.value).to eq 0
      end
    end
    describe 'pour le bit B_MAIL_DEB(2)' do
      it 'répond à add_bit_mail_deb' do
        expect(jour).to respond_to :add_bit_mail_deb
      end
      it 'répond à remove_bit_mail_deb' do
        expect(jour).to respond_to :remove_bit_mail_deb
      end
      it 'permettent d’ajouter et de retirer le bit, une seule fois' do
        expect(jour.value).to eq 0
        jour.add_bit_mail_deb
        expect(jour.value).to eq 2
        jour.add_bit_mail_deb
        expect(jour.value).not_to eq 4
        expect(jour.value).to eq 2
        jour.remove_bit_mail_deb
        expect(jour.value).to eq 0
        jour.remove_bit_mail_deb
        expect(jour.value).not_to eq -2
        expect(jour.value).to eq 0
      end
    end
    describe 'pour le bit B_ACTIF(1)' do
      it 'répond à add_bit_actif' do
        expect(jour).to respond_to :add_bit_actif
      end
      it 'répond à remove_bit_actif' do
        expect(jour).to respond_to :remove_bit_actif
      end
      it 'permettent d’ajouter et de retirer le bit' do
        expect(jour.value).to eq 0
        jour.add_bit_actif
        expect(jour.value).to eq 1
        jour.remove_bit_actif
        expect(jour.value).to eq 0
      end
      it 'n’ajoutent et ne retirent le bit qu’une seule fois' do
        expect(jour.value).to eq 0
        jour.add_bit_actif
        expect(jour.value).to eq 1
        jour.add_bit_actif
        expect(jour.value).not_to eq 2
        expect(jour.value).to eq 1
        jour.remove_bit_actif
        expect(jour.value).to eq 0
        jour.remove_bit_actif
        expect(jour.value).not_to eq -1
        expect(jour.value).to eq 0
      end
    end

    describe 'essai avec tous les bits' do
      it 'retourne toujours la bonne valeur' do
        expect(jour.value).to eq 0
        jour.add_bit_actif
        expect(jour.value).to eq 1
        jour.add_bit_mail_deb
        expect(jour.value).to eq 3
        jour.add_bit_conf_deb
        expect(jour.value).to eq 7
        jour.remove_bit_conf_deb
        expect(jour.value).to eq 3
        jour.add_bit_mail_fin
        expect(jour.value).to eq 3 + 128
        jour.add_bit_mail_fin
        jour.add_bit_mail_fin
        jour.add_bit_mail_deb
        jour.add_bit_actif
        expect(jour.value).to eq 3 + 128
        jour.add_bit_fin
        jour.add_bit_fin
        jour.add_bit_fin
        expect(jour.value).to eq 3 + 128 + 512
        jour.remove_bit_fin
        expect(jour.value).to eq 3+ 128
        jour.remove_bit_mail_fin
        expect(jour.value).to eq 3
        jour.remove_bit_mail_deb
        expect(jour.value).to eq 1
        jour.remove_bit_actif
        expect(jour.value).to eq 0
      end
    end
  end

  describe 'méthodes pour tester la valeur des bits du jour avec' do
    before(:all) do
      set_to "000110vv" # -- 4 jours à 0, 1, 10 et vv
      @jour1 = @program.day_overview(1)
      @jour2 = @program.day_overview(2)
      @jour3 = @program.day_overview(3)
      @jour4 = @program.day_overview(4)

      # puts "@program.daysoverview : #{@program.days_overview.value}"
      # puts "Valeur @jour1 : #{@jour1.value}"
      # puts "Valeur @jour2 : #{@jour2.value}"
      # puts "Valeur @jour3 : #{@jour3.value}"
      # puts "Valeur @jour4 : #{@jour4.value}"
    end
    let(:jour1) { @jour1 }
    let(:jour2) { @jour2 }
    let(:jour3) { @jour3 }
    let(:jour4) { @jour4 }

    describe 'actif?' do
      it 'répond' do
        expect(jour1).to respond_to :actif?
      end
      it 'retourne la bonne valeur' do
        expect(jour1).not_to be_actif
        expect(jour2).to be_actif
        expect(jour3).not_to be_actif
        expect(jour4).to be_actif
      end
    end
    describe 'mail_deb?' do
      it 'répond' do
        expect(jour1).to respond_to :mail_deb?
      end
      it 'retourne la bonne valeur' do
        expect(jour1).not_to be_mail_deb
        expect(jour2).not_to be_mail_deb
        expect(jour3).not_to be_mail_deb
        expect(jour4).to be_mail_deb
      end
    end
    describe 'conf_deb?' do
      it 'répond' do
        expect(jour1).to respond_to :conf_deb?
      end
      it 'retourne la bonne valeur' do
        expect(jour1).not_to be_conf_deb
        expect(jour2).not_to be_conf_deb
        jour2.add_bit_conf_deb
        expect(jour2).to be_conf_deb
        expect(jour3).not_to be_conf_deb
        expect(jour4).to be_conf_deb
      end
    end
    describe 'mail_fin?' do
      it 'répond' do
        expect(jour1).to respond_to :mail_fin?
      end
      it 'retourne la bonne valeur' do
        expect(jour1).not_to be_mail_fin
        expect(jour2).not_to be_mail_fin
        jour2.add_bit_mail_fin
        expect(jour2).to be_mail_fin
        expect(jour3).not_to be_mail_fin
        expect(jour4).to be_mail_fin
      end
    end
    describe 'forc_fin?' do
      it 'répond' do
        expect(jour1).to respond_to :forc_fin?
      end
      it 'retourne la bonne valeur' do
        expect(jour1).not_to be_forc_fin
        expect(jour2).not_to be_forc_fin
        expect(jour3).not_to be_forc_fin
        jour3.add_bit_forc_fin
        expect(jour3).to be_forc_fin
        expect(jour4).to be_forc_fin
      end
    end
    describe 'fin?' do
      it 'répond' do
        expect(jour2).to respond_to :fin?
      end
      it 'retourne la bonne valeur' do
        expect(jour1).not_to be_fin
        expect(jour2).not_to be_fin
        jour2.add_bit_fin
        expect(jour2).to be_fin
        expect(jour3).not_to be_fin
        expect(jour4).to be_fin
      end
    end

  end

  describe 'Les méthodes pour tester les jours-programme' do

    # par exemple :
    # mail_debut_sent?
    # start_confirmed_by_user?
  end
end
