describe 'Edition des exemples' do

  before(:all) do
    User::current = phil
    site.require_objet 'unan_admin'
    UnanAdmin::require_module 'exemple'
    # Il faut requérir aussi edit.rb
    require './objet/unan_admin/exemple/edit.rb'
    @exemple = Unan::Program::Exemple::new
  end

  let(:exemple) { @exemple }

  describe 'Méthodes' do

    describe 'save' do
      it 'répond' do
        expect(exemple).to respond_to :save
      end
    end

    describe 'create' do
      it 'répond' do
        expect(exemple).to respond_to :create
      end
    end


    describe 'check_data_or_raise' do
      before(:all) do
        @data = {
          titre:        "Titre de l'exemple",
          content:      "Le contenu de l'exemple",
          source:       "La source de l'exemple",
          source_year:  "1970",
          source_pays:  "us",
          source_src:   "1",
          work_id:      ""
        }
      end
      before(:each) do
        @exemple.instance_variable_set('@param_data', nil)
      end
      it 'répond' do
        expect(exemple).to respond_to :check_data_or_raise
      end
      context 'si toutes les données sont valides' do
        it 'retourne true' do
          param(:exemple => @data)
          expect(exemple.check_data_or_raise).to eq true
        end
        it 'copose un source_type correct' do
          expect(exemple.assemble_source_type).to eq "11970us"
        end
      end
      describe 'renvoie false si' do
        it 'le titre n’est pas fourni' do
          param(:exemple => @data.merge(titre:nil))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'le titre est trop long (plus de 255 caractères)' do
          param(exemple: @data.merge(titre:"c"*256))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'le contenu n’est pas fourni' do
          param(exemple: @data.merge(content:nil))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'le contenu est vide (ou pseudo vide)' do
          param(exemple: @data.merge(content:" "))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'l’année n’est pas fournie' do
          param(exemple: @data.merge(source_year:nil))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'l’année est mal formatée' do
          param(exemple: @data.merge(source_year:"xxx"))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'l’année est invalide (future)' do
          param(exemple: @data.merge(source_year:"#{Time.now.year + 2}"))
          expect(exemple.check_data_or_raise).to eq false
        end
        it 'le work-id n’existe pas' do
          ids = Unan::table_absolute_works.select(colonne:[]).collect{|h|h[:id]}
          bad_id = ids.max + 1
          param(exemple: @data.merge(work_id:"#{bad_id}"))
          expect(exemple.check_data_or_raise).to eq false
        end
      end
    end
  end

end
