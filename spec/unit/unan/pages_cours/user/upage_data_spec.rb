describe 'Méthodes de données de User::UPage' do
  before(:all) do
    @start_time = Time.now.to_i
    site.require_objet 'unan'
    Unan::require_module 'page_cours'

    @auteur       = get_any_user(:with_program => true)
    @pagecours    = User::UPage::new(@auteur, 1)
    @pagecours.create

  end

  let(:start_time) { @start_time }
  let(:auteur) { @auteur }
  let(:pagecours) { @pagecours }

  before(:each) do
    @auteur.instance_variables.each{|k|@auteur.instance_variable_set(k, nil)}
  end

  #auteur
  describe '#auteur' do
    it 'répond' do
      expect(pagecours).to respond_to :auteur
    end
    it 'retourne l’instance de l’auteur' do
      expect(pagecours.auteur).to be_instance_of User
      expect(pagecours.auteur.id).to eq auteur.id
    end
  end

  #id
  describe '#id' do
    it 'répond' do
      expect(pagecours).to respond_to :id
    end
    it 'retourne l’identifiant de la page' do
      expect(pagecours.id).to eq 1
    end
  end

  #status
  describe '#status' do
    it 'répond' do
      expect(pagecours).to respond_to :status
    end
    it 'retourne le status de la page' do
      pagecours.set(status: 5)
      expect(pagecours.status).not_to eq nil
      expect(pagecours.status).to eq 5
    end
  end

  #lectures
  describe '#lectures' do
    it 'répond' do
      expect(pagecours).to respond_to :lectures
    end
    context 'sans lecture déjà faite' do
      before(:all) do
        @pagecours.set(:lectures => nil)
      end
      it 'retourne un Array vide' do
        expect(pagecours.lectures).to be_instance_of Array
        expect(pagecours.lectures).to be_empty
      end
    end
    context 'avec des lectures déjà faites' do
      before(:all) do
        @pagecours.set(:lectures => [NOW - 20.days, NOW-7.days])
      end
      it 'retourne un Array des dates de lectures faites' do
        expect(pagecours.lectures).to be_instance_of Array
        expect(pagecours.lectures).not_to be_empty
      end
    end
  end

  #page_cours
  describe '#page_cours' do
    it 'répond' do
      expect(pagecours).to respond_to :page_cours
    end
    it 'retourne une instance Unan::Program::PageCours de la page de cours' do
      expect(pagecours.page_cours).to be_instance_of Unan::Program::PageCours
    end
    it 'retourne la bonne instance' do
      expect(pagecours.page_cours.id).to eq 1
    end
  end

  #comments
  describe '#comments' do
    it 'répond' do
      expect(pagecours).to respond_to :comments
    end
    context 'sans commentaire' do
      before(:all) do
        @pagecours.set(comments: nil)
      end
      it 'retourn nil' do
        expect(pagecours.comments).to eq nil
      end
    end
    context 'avec un commentaire' do
      before(:all) do
        @comments = "Un commentaire à #{Time.now}"
        @pagecours.set(comments: @comments)
      end
      it 'le retourne' do
        expect(pagecours.comments).to eq @comments
      end
    end
  end

  describe '#created_at' do
    it 'répond' do
      expect(pagecours).to respond_to :created_at
    end
    it 'retourne la date de création de la donnée' do
      expect(pagecours.created_at).to be >= start_time
    end
  end

  describe 'index_tdm' do
    it 'répond' do
      expect(pagecours).to respond_to :index_tdm
    end
    it 'retourne nil si non défini' do
      pagecours.set(index_tdm: nil)
      expect(pagecours.index_tdm).to eq nil
    end
    it 'retourne la valeur définie if any' do
      pagecours.set(index_tdm: 12)
      expect(pagecours.index_tdm).to eq 12
    end
  end
end
