describe 'Méthodes pour gérer les Quiz d’auteur' do

  before(:all) do
    degel 'before-test'
    reset_all_variables
    site.require_objet 'unan'
    Unan::require_module 'quiz'
    @quiz = Unan::Quiz::new(1)

    @current_user = create_user(:unanunscript => true)
    @autre_auteur = create_user(:unanunscript => true)

    # Noter que si l'on avait mis `current:true` en argument de la
    # méthode create_user, cela n'aurait servi à rien puisque la
    # création d'un programme UN AN UN SCRIPT met automatiquement
    # l'auteur en auteur courant.
    # Donc il faut remettre ici l'auteur courant
    reset_all_variables
    User::current = @current_user

  end

  let(:quiz) { @quiz }


  describe '#uquiz' do
    it 'répond' do
      expect(quiz).to respond_to :uquiz
    end
    context 'sans argument' do
      before(:all) do
        User::current = @current_user
      end
      it 'retourne un quiz de l’auteur courant (user)' do
        res = quiz.uquiz
        expect(res).to be_instance_of User::UQuiz
        expect(res.id).to eq quiz.id
        expect(res.auteur.id).to eq @current_user.id
      end
    end
    context 'avec un argument' do
      it 'retourne le quiz de l’auteur en argument' do
        res = quiz.uquiz(@autre_auteur)
        expect(res).to be_instance_of User::UQuiz
        expect(res.id).to eq quiz.id
        expect(res.auteur.id).to eq @autre_auteur.id
      end
    end
  end
end
