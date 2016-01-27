describe 'Méthode ::get' do

  before(:all) do
    site.require_objet 'forum'
  end

  it 'répond' do
    expect(Forum::Sujet).to respond_to :get
  end

  it 'retourne une instance Forum::Sujet' do
    res = Forum::Sujet::get(1)
    expect(res).to be_instance_of Forum::Sujet
    expect(res.id).to eq 1
  end
end
