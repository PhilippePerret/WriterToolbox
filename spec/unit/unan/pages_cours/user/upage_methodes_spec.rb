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

  def reset_variables_page
    auteur_sym  = '@auteur'.to_sym.freeze
    id_sym      = '@id'.to_sym.freeze
    @auteur.instance_variables.each do |k|
      next if [id_sym].include?(k)
      @auteur.instance_variable_set(k, nil)
    end
    @pagecours.instance_variables.each do |k|
      next if [auteur_sym, id_sym].include?(k)
      @pagecours.instance_variable_set(k,nil)
    end
  end

  before(:each) do
    reset_variables_page
  end

  #add_lecture
  describe '#add_lecture' do
    it 'répond' do
      expect(pagecours).to respond_to :add_lecture
    end
    it 'ajoute une lecture à cette page' do
      pagecours.set(lectures: nil)
      pagecours.add_lecture
      lect = pagecours.lectures
      expect(lect).not_to eq nil
      expect(lect).to be_instance_of Array
      expect(lect.count).to eq 1
    end
  end

  #status=
  describe 'status=' do
    it 'répond' do
      expect(pagecours).to respond_to :status=
    end
    context 'avec un argument invalide' do
      it 'produit une erreur d’argument' do
        [true, Unan, {un:"hash"}, ["un", "array"], :symbole].each do |typ|
          expect{pagecours.status= typ}.to raise_error ArgumentError
        end
      end
    end
    context 'avec un nombre trop grand' do
      it 'produit une erreur d’argument' do
        expect{pagecours.status= 12}.to raise_error ArgumentError, "Le status doit valoir entre 0 et 9."
      end
    end
    context 'avec un nombre correct' do
      it 'définit le status de la page' do
        pagecours.set(status: 0)
        expect(pagecours.status).to eq 0
        pagecours.instance_variable_set('@status', nil)
        pagecours.status = 8
        expect(pagecours.status).to eq 8
      end
    end
  end

end
