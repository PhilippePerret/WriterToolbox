describe 'forum.sujets.where_clause_from' do
  before(:all) do
    site.require_objet 'forum'
    degel 'forum-with-messages'

    @creator = Forum::get_any_admin
  end

  it 'répond' do
    expect(forum.sujets).to respond_to :where_clause_from
  end

  context 'avec :creator_id' do
    it 'retourne le bon where et values' do
      w, v = forum.sujets.where_clause_from(creator_id: 12)
      expect(w).not_to eq nil
      expect(w).to eq "creator_id = ?"
      expect(v).to eq [12]
    end
  end
  context 'avec :creator' do
    it 'retourne le bon where et values' do
      where, values = forum.sujets.where_clause_from(creator: @creator)
      expect(where).to eq "creator_id = ?"
      expect(values).to eq [@creator.id]
    end
  end

  context 'avec :created_after' do
    it 'retourne le bon where et values' do
      now = NOW - 4.days
      where, values = forum.sujets.where_clause_from(created_after: now)
      expect(where).to eq "created_at >= ?"
      expect(values).to eq [now]
    end
  end

  context 'avec :created_before' do
    it 'retourne le bon where et values' do
      now = NOW - 4.days
      where, values = forum.sujets.where_clause_from(created_before: now)
      expect(where).to eq "created_at < ?"
      expect(values).to eq [now]
    end
  end

  context 'avec :categories' do
    it 'retourne le bon where et values avec une catégorie unique' do
      where, values = forum.sujets.where_clause_from(categories: 2)
      expect(where).to eq "categories = ?"
      expect(values).to eq [2]
    end
    it 'retourne le bon where et values avec plusieurs catégories' do
      where, values = forum.sujets.where_clause_from(categories: [2,12])
      expect(where).to eq "categories IN ?"
      expect(values).to eq [[2,12]]
    end
  end

  context 'avec :name' do
    it 'retourne le bon where et values pour une recherche sur le nom' do
      where, values = forum.sujets.where_clause_from(name: "ce sujet")
      expect(where).to eq "name LIKE ?"
      expect(values).to eq ["%ce sujet%"]
    end
  end

end
