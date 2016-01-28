describe '::where_clause_from' do
  before(:all) do
    site.require_objet 'forum'
    FP = Forum::Post
  end
  # Méthode qui prend un filtre de conditions et retourne
  # la clause WHERE en résultant
  describe 'Forum::Post::where_clause_from' do
    it 'répond' do
      expect(FP).to respond_to :where_clause_from
    end

    context 'avec un filtre nil' do
      it 'retourne [nil, nil]' do
        expect(FP::where_clause_from(nil)).to eq [nil, nil]
      end
    end

    context 'avec un user_id dans le filtre' do
      it 'retourne la clause user_id' do
        where, values = FP::where_clause_from(user_id: 12)
        expect(where).to match "user_id = ?"
        expect(values).to eq [12]
      end
    end

    context 'avec un user dans le filtre' do
      it 'retourne la clause avec user_id' do
        u = get_any_user
        where, values = FP::where_clause_from(user: u)
        expect(where).to match "user_id = ?"
        expect(values).to eq [u.id]
      end
    end

    context 'avec un created_after dans le filtre' do
      it 'retourne la clause sur created_at' do
        now = NOW - 4.days
        where, values = FP::where_clause_from(created_after: now)
        expect(where).to match "created_at >= ?"
        expect(values).to eq [now]
      end
    end

    context 'avec un created_before dans le filtre' do
      it 'retourne la clause sur created_at' do
        now = NOW - 10.days
        where, values = FP::where_clause_from(created_before: now)
        expect(where).to match "created_at < ?"
        expect(values).to eq [now]
      end
    end

    context 'avec un valid à true dans le filtre' do
      it 'retourne la clause sur options' do
        where, values = FP::where_clause_from(valid: true)
        expect(where).to match "options LIKE ?"
        expect(values).to eq ['1%']
      end
    end

    context 'avec un valid à false dans le filtre' do
      it 'retourne la clause sur options' do
        where, values = FP::where_clause_from(valid: false)
        expect(where).to match "options LIKE ?"
        expect(values).to eq ['0%']
      end
    end

    context 'avec un content dans le filtre' do
      it 'retourne la clause sur content' do
        where, values = FP::where_clause_from(content: "crocodile")
        expect(where).to match "content LIKE ?"
        expect(values).to eq ["%crocodile%"]
      end
    end

    context 'avec un filtre complexe' do
      it 'retourne la clause where correcte' do
        now_after   = NOW - 2.days
        now_before  = NOW - 1.days
        where,values = FP::where_clause_from(content:"crocodile", created_after: now_after, user_id: 12, created_before: now_before)
        expect(where).to eq "user_id = ? AND created_at >= ? AND created_at < ? AND content LIKE ?"
        expect(values).to eq [12, now_after, now_before, "%crocodile%"]
      end
    end
  end
end
