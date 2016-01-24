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
end
