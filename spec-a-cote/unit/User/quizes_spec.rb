describe 'Méthodes de quiz de l’auteur' do
  before(:all) do
    degel 'benoit-2e-pday-after-quiz'

    site.require_objet 'unan'
    Unan::require_module 'quiz'

    @user = benoit

  end

  let(:user) { @user }

  describe '#quizes' do
    it 'répond' do
      expect(user).to respond_to :quizes
    end
    context 'sans argument' do
      it 'retourne un hash de toutes les instances de quiz de l’auteur' do
        nombre_quizes = user.table_quiz.count
        res = user.quizes
        expect(res).to be_instance_of Hash
        expect(res).not_to be_empty
        expect(res.count).to eq nombre_quizes
        expect(res.values.first).to be_instance_of( User::UQuiz )
      end
    end

    describe 'avec un argument' do
      before(:all) do
        # On commence par copier des instances du premier quiz (le seul)
        # pour avoir plusieurs exemplaires de quiz
        hquiz = @user.table_quiz.select(limit:1).first
        @hquiz1_id = hquiz[:id]
        hquiz[:quiz_id]       = 2
        hquiz[:points]        = 50
        hquiz[:created_at]    = NOW - 2.days
        @user.table_quiz.update(@hquiz1_id, hquiz)
        @hquiz2 = hquiz.dup
        @hquiz2.delete(:id)
        @hquiz2[:created_at]  = NOW - 7.days
        @hquiz2[:points]      = 100
        @hquiz2[:quiz_id]     = 10
        @hquiz2_id = @user.table_quiz.insert(@hquiz2)
        @hquiz2[:id] = @hquiz2_id
        @hquiz3 = hquiz.dup
        @hquiz3.delete(:id)
        @hquiz3[:created_at] = NOW - 14.days
        @hquiz3[:points]     = 200
        @hquiz3_id = @user.table_quiz.insert(@hquiz3)
        @hquiz4 = hquiz.dup
        @hquiz4.delete(:id)
        @hquiz4[:created_at] = NOW - 15.days
        @hquiz4[:points]     = 300
        @hquiz4_id = @user.table_quiz.insert(@hquiz4)
      end
      before(:each) do
        user.instance_variable_set('@all_quizes', nil)
      end
      it 'retourne la liste filtrée des quiz' do
        qs = user.quizes(created_after: Time.now.to_i)
        expect(qs).to be_instance_of Hash
        expect(qs).to be_empty
      end
      context 'avec un filtre sur :quiz_id' do
        it 'retourne les bons questionnaire' do
          res = user.quizes(quiz_id: 10)
          expect(res.count).to eq 1
          premier = res.values.first
          expect(premier).to be_instance_of User::UQuiz
          expect(premier.id).to eq @hquiz2_id
        end
      end
      context 'avec un filtre sur :created_after' do
        it 'retourne les quiz créés après la date fournie' do
          res = user.quizes(created_after:  NOW - 10.days)
          expect(res.count).to eq 2
          qcms  = res.values
          ids   = [@hquiz1_id, @hquiz2_id]
          expect(ids).to include(qcms.first.id)
          expect(ids).to include(qcms.last.id)
        end
      end
      context 'avec un filtre sur :created_before' do
        it 'retourne les quiz créés avant la date ' do
          res = user.quizes(created_before:  NOW - 10.days)
          expect(res.count).to eq 2
          qcms  = res.values
          ids   = [@hquiz3_id, @hquiz4_id]
          expect(ids).to include(qcms.first.id)
          expect(ids).to include(qcms.last.id)
        end
      end
      context 'avec un filtre sur :max_points' do
        it 'retourne les quiz ayant moins de :max_points' do
          res = user.quizes(max_points: 250)
          expect(res.count).to eq 3
          qcm_keys = res.keys
          [@hquiz1_id, @hquiz2_id, @hquiz3_id].each do |qid|
            expect(qcm_keys).to include qid
          end
        end
      end

      context 'avec un filtre sur :min_points' do
        it 'retourne les quiz ayant plus de :min_points' do
          res = user.quizes(min_points: 250)
          expect(res.count).to eq 1
          expect(res.keys.first).to eq @hquiz4_id
        end
      end

      context 'avec un filtre qui a tout' do
        it 'retourne les quiz correspondant au filtre' do
          res = user.quizes(min_points: 100, created_after: NOW-8.days, created_before:NOW-5.days)
          expect(res.count).to eq 1
          expect(res.keys.first).to eq @hquiz2_id
        end
      end
    end
  end
end
