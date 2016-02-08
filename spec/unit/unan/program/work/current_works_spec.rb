describe 'Unan::Program#current_works' do
  before(:all) do

    benoit.set_pday_to( 4 )
    @program = benoit.program

  end

  let(:program) { @program }

  it 'le programme répond' do
    expect(program).to respond_to :current_works
  end
  it 'l’auteur répond' do
    expect(benoit).to respond_to :current_works
  end

  describe 'vérification' do
    it 'benoit possède des travaux finis' do
      completed_works = benoit.table_works.select(where:"status = 9").values
      expect(completed_works).not_to be_empty
    end
    it 'benoit possède des travaux non finis' do
      cur_works = benoit.table_works.select(where:"status != 9").values
      expect(cur_works).not_to be_empty
    end
  end

  describe 'current_works suivant arguments :as' do
    before(:all) do
      @cur_works  = benoit.table_works.select(where:"status != 9")
      @works_ids  = @cur_works.keys
      @works_data = @cur_works.values
    end
    context 'avec des travaux définis et non finis' do
      it 'current_works retourne seulement les travaux non finis' do
        benoit.current_works(as: :data).each do |dwork|
          expect(dwork[:status]).to be < 9
        end
      end
    end
    context 'avec un argument :as :ids/:id' do
      it 'current_works retourne les identifiants des travaux non finis' do
        resids = benoit.current_works(as: :ids)
        expect(resids).to eq @works_ids
        resid = benoit.current_works(as: :id)
        expect(resid).to eq @works_ids
      end
    end
    context 'avec un argument :as :data' do
      it 'current_works retourne les données des travaux non finis comme Hash' do
        resdata = benoit.current_works(as: :data)
        expect(resdata).to eq @works_data
      end
    end
    context 'avec un argument :as :instance(s)' do
      it 'current_works retourne les instances des travaux non finis' do
        resinst = benoit.current_works(as: :instance)
        expect(resinst.first).to be_instance_of Unan::Program::Work
        resinsts = benoit.current_works(as: :instances)
        expect(resinsts.first).to be_instance_of Unan::Program::Work
      end
    end

  end

end
