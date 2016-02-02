describe 'User::UQuiz::get' do
  before(:all) do
    site.require_objet 'unan'
    Unan::require_module 'quiz'

    @current_auteur = create_user(unanunscript:true)
    # => mis en auteur courant
    @autre_auteur = create_user(unanunscript:true)
    # => mis en auteur courant

    reset_all_variables
    User::UQuiz.instance_variables.each{|iv| User::UQuiz.remove_instance_variable(iv)}
  end

  it 'répond' do
    expect(User::UQuiz).to respond_to :get
  end

  context 'sans argument auteur' do
    before(:all) do
      User::current = @current_auteur
    end
    it 'retourne un quiz de l’user courant' do
      res = User::UQuiz::get 10
      expect(res).to be_instance_of User::UQuiz
      expect(res.id).to eq 10
      expect(res.auteur.id).to eq @current_auteur.id
    end
  end

  context 'avec un argument auteur' do
    it 'retourne un quiz de l’user en argument' do
      res = User::UQuiz::get 10, @autre_auteur
      expect(res).to be_instance_of User::UQuiz
      expect(res.id).to eq 10
      expect(res.auteur.id).to eq @autre_auteur.id
    end
  end
end
