describe 'Calcul des points d’une question' do
  before(:all) do
    site.require_objet 'unan'
    Unan::require_module 'quiz'
    @question = Unan::Quiz::Question::new( 1 )
    @reponses = @question.reponses
  end

  def set_reponses_to hreponses
    @question.instance_variable_set('@reponses', hreponses)
    @question.instance_variable_set('@max_points', nil)
  end

  let(:question) { @question }
  let(:reponses) { @reponses }

  describe 'Unan::Quiz::Question#max_points' do
    it { expect(question).to respond_to :max_points }
    context 'avec des réponses à points' do
      before(:all) do
        @max_points = 100
        @reponses[0][:points] = @max_points
        set_reponses_to @reponses
      end
      it 'retourne le nombre de points maximum de la question' do
        expect(question.max_points).to eq @max_points
      end
    end
    context 'avec des réponses sans points' do
      before(:all) do
        set_reponses_to(@reponses.collect{|hrep|hrep[:points] = nil;hrep})

      end
      it 'retourne nil' do
        expect(question.max_points).to eq nil
      end
    end
  end
end
