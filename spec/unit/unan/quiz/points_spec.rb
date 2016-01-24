describe 'Méthodes de calcul de points du quiz' do
  before(:all) do
    site.require_objet 'unan'
    Unan::require_module 'quiz'
    @quiz = Unan::Quiz::new(1)
  end

  let(:quiz) { @quiz }

  describe '#max_points' do
    it 'répond' do
      expect(quiz).to respond_to :max_points
    end
    context 'avec un questionnaire sans points' do
      before(:all) do
        @quiz.questions.each do |question|
          question.instance_variable_set('@max_points', 0)
        end
      end
      it 'retourne nil' do
        expect(quiz.max_points).to eq nil
      end
    end
    context 'avec un questionnaire à points' do
      before(:all) do
        @max_points = 0
        @quiz.questions.each do |question|
          question.instance_variable_set('@max_points', 500)
          @max_points += 500
        end
      end
      it 'retourne la sommes des points maximum' do
        expect(quiz.max_points).to eq @max_points
      end
    end
  end


  describe 'Unan::Quiz::note_sur_20_for' do
    it 'répond' do
      expect(quiz).to respond_to :note_sur_20_for
    end
    context 'avec un questionnaire de type sans compte' do
      it 'retourne nil si c’est un simple questionnaire de renseignement' do
        quiz.instance_variable_set('@type', 1)
        expect(quiz.note_sur_20_for(20)).to eq nil
      end
      it 'retourne nil si c’est un sondage' do
        quiz.instance_variable_set('@type', 7)
        expect(quiz.note_sur_20_for(20)).to eq nil
      end
    end
    context 'avec un questionnaire dont le total est nil' do
      before(:all) do
        @quiz.instance_variable_set('@type', 2)
        @quiz.instance_variable_set('@max_points', 0)
      end
      it 'retourne nil' do
        expect(quiz.note_sur_20_for(10)).to eq nil
      end
    end
    context 'avec un argument à nil (et un questionnaire avec des points — n’arrive pas, normalement)' do
      before(:all) do
        @quiz.instance_variable_set('@type', 2)
        @quiz.instance_variable_set('@max_points', 1000)
      end
      it 'retourne nil' do
        expect(quiz.note_sur_20_for(nil)).to eq nil
      end
    end
    context 'avec un questionnaire à points' do
      it 'retourne la bonne valeur si c’est une validation des acquis' do
        quiz.instance_variable_set('@type', 2)
        quiz.instance_variable_set('@max_points', 1000)
        {
          1000 => 20,
          750 => 15,
          730 => 14.6,
          500 => 10,
          250 => 5,
          200 => 4,
          100 => 2
        }.each do |points, valsur20|
          expect(quiz.note_sur_20_for(points)).to eq valsur20
        end
      end
    end
  end
end
