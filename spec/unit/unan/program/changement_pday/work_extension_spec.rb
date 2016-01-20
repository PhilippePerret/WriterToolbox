=begin
Test de l'extension de Unan::Program::Work pour le changement de jour-programme
=end
describe 'Extension Unan::Program::Work pour le changement de P-Day' do
  before(:all) do
    site.require_objet 'unan'
    Unan::require_module "start_pday"
    @program  = get_any_program
    @work     = Unan::Program::Work::new(@program, nil)
  end
  let(:work) { @work }

  def regle created_at, duree_relative
    @work.instance_variable_set('@created_at', created_at)
    @work.instance_variable_set('@duree_relative', duree_relative)
    @work.instance_variable_set('@niveau_avertissement', nil)
    @work.instance_variable_set('@depassement', nil)
  end

  describe '#niveau_avertissement' do
    it 'répond' do
      expect(work).to respond_to :niveau_avertissement
    end
    context 'avec un travail qui n’est pas encore en dépassement' do
      it 'retourne nil' do
        regle NOW - 60, 120
        expect(work.niveau_avertissement).to eq nil
      end
    end
    context 'avec un travail en dépassement de 1 à 2 jours' do
      it 'retourne 1' do
        (1..2).each do |ijour|
          regle ( NOW - (ijour + 1).days ), 1.days
          expect(work.niveau_avertissement).to eq 1
        end
      end
    end
    context 'avec un travail qui est en dépassement de 3 à 6 jours' do
      it 'retourne 2' do
        (3..6).each do |ijour|
          regle ( NOW - (ijour + 1).days ), 1.days
          expect(work.niveau_avertissement).to eq 2
        end
      end
    end
    context 'avec un travail en dépasse de 7 à 14 jours' do
      it 'retourne 3' do
        (7..14).each do |ijour|
          regle ( NOW - (ijour + 1).days ), 1.days
          expect(work.niveau_avertissement).to eq 3
        end
      end
    end
    context 'avec un travail en dépassement de 15 à 30 jours' do
      it 'retourne 4' do
        (15..30).each do |ijour|
          regle ( NOW - (ijour + 1).days ), 1.days
          expect(work.niveau_avertissement).to eq 4
        end
      end
    end
    context 'avec un travail en dépassement de 31 à 46 jours' do
      it 'retourne 5' do
        (31..46).each do |ijour|
          regle ( NOW - (ijour + 1).days ), 1.days
          expect(work.niveau_avertissement).to eq 5
        end
      end
    end
    context 'avec un travail en dépassement de plus de 46 jours' do
      it 'retourne 6' do
        (47..60).each do |ijour|
          regle ( NOW - (ijour + 1).days ), 1.days
          expect(work.niveau_avertissement).to eq 6
        end
      end
    end
  end

  describe '#message_avertissement' do
    it 'répond' do
      expect(work).to respond_to :message_avertissement
    end
  end

end
