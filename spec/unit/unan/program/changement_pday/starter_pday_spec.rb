describe 'Méthodes de Unan::Program::StarterPDay' do

  def init_all_variables
    [:current_pday, :works_ids].each do |k|
      @program.auteur.instance_variable_set("@#{k}", nil)
    end
    [:current_pday].each do |k|
      @program.instance_variable_set("@#{k}", nil)
    end
    [
      :pday, :abs_pday, :has_new_works, :current_pday, :next_pday,
      :work_ids, :works
    ].each do |k|
      @starter.instance_variable_set("@#{k}", nil)
    end
  end

  before(:all) do
    site.require_objet 'unan'
    Unan::require_module 'start_pday'

    @program_id = Unan::table_programs.select(where:"options LIKE '1%'", colonnes:[:id]).keys.first
    @program = Unan::Program::new @program_id

  end
  let(:program_id)  { @program_id     }
  let(:program)     { @program        }
  let(:auteur)      { @program.auteur }

  it 'la class Unan::Program::StarterPDay existe' do
    expect(defined?(Unan::Program::StarterPDay)).to eq "constant"
  end

  describe 'Instanciation' do
    context 'avec un programme valide' do
      it 'retourne une instance valide' do
        res = Unan::Program::StarterPDay::new program
        expect(res).to be_instance_of Unan::Program::StarterPDay
        expect(res.program.id).to eq program_id
      end
    end
  end

  describe 'Méthodes d’instance' do
    before(:all) do
      @starter = Unan::Program::StarterPDay::new( @program )

    end
    let(:starter) { @starter }

    # ---------------------------------------------------------------------
    #   Méthodes de data
    # ---------------------------------------------------------------------
    describe '#current_pday' do
      it 'répond' do
        expect(starter).to respond_to :current_pday
      end
      it 'retourne la bonne valeur' do
        starter.instance_variable_set('@current_pday', nil)
        program.auteur.instance_variable_set('@current_pday', nil)
        program.auteur.set_var(:current_pday, 6)
        expect(starter.current_pday).to eq 6
        starter.instance_variable_set('@current_pday', nil)
        program.auteur.instance_variable_set('@current_pday', nil)
        program.auteur.set_var(:current_pday, 2)
        expect(starter.current_pday).to eq 2
      end
    end
    describe '#next_pday' do
      before(:each) do
        @starter.instance_variable_set('@next_pday', nil)
        @starter.instance_variable_set('@current_pday', nil)
      end
      it 'répond' do
        expect(starter).to respond_to :next_pday
      end
      it 'retourne la bonne valeur' do
        program.auteur.set_var(:current_pday, 3)
        expect(starter.next_pday).to eq 4
      end
      it 'retourne la bonne valeur' do
        program.auteur.set_var(:current_pday, 356)
        expect(starter.next_pday).to eq 357
      end
    end

    describe '#abs_pday' do
      it 'répond' do
        expect(starter).to respond_to :abs_pday
      end
      it 'retourne une instance AbsPDay' do
        expect(starter.abs_pday).to be_instance_of Unan::Program::AbsPDay
      end
      it 'une instance avec le bon indice' do
        expect(starter.abs_pday.id).to eq starter.next_pday
      end
    end

    describe '#pday' do
      it 'répond' do
        expect(starter).to respond_to :pday
      end
      it 'retourne une instance PDay' do
        expect(starter.pday).to be_instance_of Unan::Program::PDay
      end
      it 'l’instance a le bon programme' do
        expect(starter.pday.program.id).to eq program.id
      end
      it 'l’instance a le bon indice (le même que le jour-programme)' do
        expect(starter.pday.id).to eq starter.next_pday
      end
    end

    describe '#work_ids' do
      it 'répond' do
        expect(starter).to respond_to :work_ids
      end
      context 'sans travail (tous exécutés)' do
        before(:all) do
          @array_ids_travaux = []
          @program.auteur.set_var(:works_ids, @array_ids_travaux)
          init_all_variables
        end
        it 'retourne une liste vide' do
          expect(starter.work_ids).to be_instance_of Array
          expect(starter.work_ids).to be_empty
        end
      end
      context 'avec des travaux non exécutés' do
        before(:all) do
          @array_ids_travaux = [12, 15, 69]
          @program.auteur.set_var(:works_ids, @array_ids_travaux)
          init_all_variables
        end
        it 'retourne la liste des ids de travaux' do
          expect(starter.work_ids).to be_instance_of Array
          expect(starter.work_ids).to eq @array_ids_travaux
        end
      end
    end

    describe 'works' do
      it 'répond' do
        expect(starter).to respond_to :works
      end
      context 'sans travaux courant' do
        before(:all) do
          @liste_work_ids = nil
          @program.auteur.set_var(:works_ids, @liste_work_ids)
          init_all_variables
        end
        it 'retourne une liste vide' do
          expect(starter.works).to be_instance_of Array
          expect(starter.works).to be_empty
        end
      end
      context 'avec des travaux courants' do
        before(:all) do
          @liste_work_ids = [12,56,89]
          @program.auteur.set_var(:works_ids, @liste_work_ids)
          init_all_variables
        end
        it 'retourne une liste des instances Unan::Program::Works' do
          expect(starter.works).to be_instance_of Array
          starter.works.each do |iw|
            expect(iw).to be_instance_of Unan::Program::Work
            expect(@liste_work_ids).to include iw.id
          end
        end
      end
    end
    # ---------------------------------------------------------------------
    #   Méthodes d'état
    # ---------------------------------------------------------------------
    describe '#has_new_works?' do
      before(:all) do
        @existant, @inexistant = nil, nil
        ids = Unan::table_absolute_pdays.select(colonnes:[:id]).keys
        (1..365).each do |icheck|
          if ids.include?(icheck)
            @existant = icheck.freeze
          else
            @inexistant = icheck.freeze
          end
          break if @existant != nil && @inexistant != nil
        end
      end
      it 'répond' do
        expect(starter).to respond_to :has_new_works?
      end
      context 'avec un jour-programme existant' do
        before(:each) do
          @starter.instance_variable_set('@next_pday', @existant)
          @starter.instance_variable_set('@abs_pday', nil)
        end
        it 'retourne true' do
          expect(starter).to have_new_works
        end
      end
      context 'avec un jour-program inexistant' do
        before(:each) do
          @starter.instance_variable_set('@next_pday', @inexistant)
          @starter.instance_variable_set('@abs_pday', nil)
        end
        it 'retourne false' do
          expect(starter).not_to have_new_works
        end
      end

    end

    describe 'mail_journalier?' do
      before(:each) do
        @starter.instance_variable_set('@want_mail_journalier', nil)
      end
      it 'répond' do
        expect(starter).to respond_to :mail_journalier?
      end
      context 'quand l’auteur veut un mail journalier' do
        before(:each) do
          @program.auteur.instance_variable_set('@has_daily_summary', true)
        end
        it 'retourne true' do
          expect(starter).to be_mail_journalier
        end
      end
      context 'quand l’auteur ne veut pas de mail journalier' do
        before(:each) do
          @program.auteur.instance_variable_set('@has_daily_summary', false)
        end
        it 'retourne false' do
          expect(starter).not_to be_mail_journalier
        end
      end
    end

    describe 'avertir_administration?' do
      it 'répond' do
        expect(starter).to respond_to :avertir_administration?
      end
      context 's’il faut avertir l’administration' do
        it 'retourne true' do
          starter.instance_variable_set('@avertir_administration', true)
          expect(starter).to be_avertir_administration
        end
      end
      context 's’il ne faut pas avertir l’administration' do
        it 'retourne false' do
          starter.instance_variable_set('@avertir_administration', false)
          expect(starter).not_to be_avertir_administration
        end
      end
    end

    # ---------------------------------------------------------------------
    #   Méthodes
    # ---------------------------------------------------------------------
    describe '#active_next_pday' do
      it 'répond' do
        expect(starter).to respond_to :active_next_pday
      end
    end


    describe '#check_validite_program' do
      it 'répond' do
        expect(starter).to respond_to :check_validite_program
      end
      it 'retourne true (toujours, pour le moment)' do
        expect(starter.check_validite_program).to eq true
      end
    end


    describe '#etat_des_lieux_program' do
      it 'répond' do
        expect(starter).to respond_to :etat_des_lieux_program
      end
      context 'sans rencontrer d’erreur' do
        it 'retourne true' do
          expect(starter.etat_des_lieux_program).to eq true
        end
      end
    end

    describe '#proceed_changement_pday' do
      it 'répond' do
        expect(starter).to respond_to :proceed_changement_pday
      end
      context 'sans rencontrer d’erreur' do

        it 'retourne true' do
          expect(starter.proceed_changement_pday).to eq true
        end

        it 'modifie le current_pday de l’auteur' do
          init_all_variables
          auteur.set_var(:current_pday, 3)
          expect(program.current_pday).to eq 3
          init_all_variables
          starter.proceed_changement_pday # <=== test
          expect(program.current_pday).to eq 4
        end
      end
    end


    describe '#send_mail_auteur_if_needed' do
      it 'répond' do
        expect(starter).to respond_to :send_mail_auteur_if_needed
      end
      context 'sans erreur' do
        it 'retourne true' do
          expect(starter.send_mail_auteur_if_needed).to eq true
        end
      end
    end


  end
end
