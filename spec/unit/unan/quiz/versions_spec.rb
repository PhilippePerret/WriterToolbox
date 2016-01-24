describe 'Test du versionning des questionnaires' do
  before(:all) do
    site.require_objet 'unan'
    Unan::require_module 'quiz'
    @quiz = Unan::Quiz::new(1)
  end

  let(:quiz) { @quiz }

  def set_version_to id
    opts = @quiz.options
    opts[3..8] = id.to_i.to_s.rjust(6,"0")
    @quiz.set(options: opts)
    @quiz.instance_variable_set('@previous_version', nil)
    @quiz.instance_variable_set('@previous_version_id', nil)
  end

  def set_next_version_to id
    opts = @quiz.options
    opts[9..14] = id.to_i.to_s.rjust(6,"0")
    @quiz.set(options: opts)
    @quiz.instance_variable_set('@next_version', nil)
    @quiz.instance_variable_set('@next_version_id', nil)
  end

  describe 'Unan::Quiz::previous_version_id' do
    it 'répond' do
      expect(quiz).to respond_to :previous_version_id
    end
    context 'sans version précédente' do
      before(:each) do
        set_version_to nil
      end
      it 'retourne nil' do
        expect(quiz.previous_version_id).to eq nil
      end
    end
    context 'avec version précédente' do
      before(:each) do
        set_version_to 1000
      end
      it 'retourne le fixnum de la version' do
        expect(quiz.previous_version_id).to eq 1000
      end
    end
  end
  describe 'Unan::Quiz#previous_version' do
    it 'répond' do
      expect(quiz).to respond_to :previous_version
    end
    context 'sans version précédente' do
      before(:each) do
        set_version_to nil
      end
      it 'retourne nil' do
        expect(quiz.previous_version).to eq nil
      end
    end
    context 'avec une version précédente' do
      before(:each) do
        set_version_to 1000
      end
      it 'retourne l’instance de la version précédente' do
        res = quiz.previous_version
        expect(res).not_to eq nil
        expect(res).to be_instance_of Unan::Quiz
        expect(res.id).to eq 1000
      end

    end
  end

  describe 'Unan::Quiz::next_version_id' do
    it 'répond' do
      expect(quiz).to respond_to :next_version_id
    end
    context 'sans version suivant' do
      before(:each) do
        set_next_version_to nil
      end
      it 'retourne nil' do
        expect(quiz.next_version_id).to eq nil
      end
    end
    context 'avec une version suivante' do
      before(:each) do
        set_next_version_to 2000
      end
      it 'retourne l’identifiant de la version suivante' do
        expect(quiz.next_version_id).to eq 2000
      end
    end
  end
  describe 'Unan::Quiz::next_version' do
    it 'répond' do
      expect(quiz).to respond_to :next_version
    end
    context 'sans version suivante' do
      before(:each) do
        set_next_version_to nil
      end
      it 'retourne nil' do
        expect(quiz.next_version).to eq nil
      end
    end
    context 'avec une version suivante' do
      before(:each) do
        set_next_version_to 2000
      end
      it 'retourne l’instance Quiz de la version suivante' do
        res = quiz.next_version
        expect(res).not_to eq nil
        expect(res).to be_instance_of Unan::Quiz
        expect(res.id).to eq 2000
      end
    end
  end

  describe 'Unan::Quiz::set_previous_version' do
    it 'répond' do
      expect(quiz).to respond_to :set_previous_version
    end
    it 'définit la version précédente' do
      set_version_to nil
      expect(quiz.previous_version).to eq nil
      quiz.set_previous_version 1200
      expect(quiz.previous_version_id).not_to eq nil
      expect(quiz.previous_version_id).to eq 1200
      quiz.set_previous_version nil
      expect(quiz.previous_version).to eq nil
    end
  end

  describe 'Unan::Quiz::set_next_version' do
    it 'répond' do
      expect(quiz).to respond_to :set_next_version
    end
    it 'définit la version suivante' do
      set_next_version_to nil
      expect(quiz.next_version).to eq nil
      quiz.set_next_version 800
      expect(quiz.next_version_id).not_to eq nil
      expect(quiz.next_version_id).to eq 800
      expect(quiz.next_version).not_to eq nil
      quiz.set_next_version nil
      expect(quiz.next_version).to eq nil
    end
  end

end
