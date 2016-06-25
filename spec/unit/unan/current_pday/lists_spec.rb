=begin

  Pour tester les listes de <user>.current_pday qui contiennent
  tous les travaux (à faire, à démarrer, en dépassement, etc.)
=end
describe 'Listes de jour-programme courant (user.current_pday)' do
  before(:all) do
    site.require_objet 'unan'
    prepare_auteur pday: 1
  end
  let(:cp) { @cp }
  context 'Un auteur au premier jour du programme' do
    before(:all) do
      @cp = @up.current_pday
    end
    describe '#aworks_until_today' do
      it 'répond et retourne une liste' do
        expect(cp).to respond_to :aworks_until_today
        expect(cp.aworks_until_today).to be_instance_of Array
      end
      it 'ne retourne qu’un seul élément' do
        expect(cp.aworks_until_today.count).to eq 1
      end
    end
    describe '#uworks_undone' do
      it 'répond et retourne la liste des inachevés' do
        expect(cp).to respond_to :uworks_undone
        expect(cp.uworks_undone).to be_instance_of Array
      end
      it 'retourne un seul élément (le premier travail)' do
        expect(cp.uworks_undone.count).to eq 0
      end
    end
    describe '#aworks_unstarted' do
      it 'répond et retourne une liste' do
        expect(cp).to respond_to :aworks_unstarted
        expect(cp.aworks_unstarted).to be_instance_of Array
      end
      it 'retourne un seul élément' do
        expect(cp.aworks_unstarted.count).to eq 0
        # Noter que la liste unstarted ne contient PAS TOUS les
        # travaux à démarrer, mais seulement les travaux qui
        # auraient dû être démarrés et qui ne l'ont pas été.
      end
    end
    describe '#uworks_goon' do
      it 'répond et retourne une liste' do
        expect(cp).to respond_to :uworks_goon
        expect(cp.uworks_goon).to be_instance_of Array
      end
      it 'retourne aucun élément' do
        expect(cp.uworks_goon.count).to eq 0
      end
    end
    describe '#uworks_recent' do
      it 'répond et retourne une liste' do
        expect(cp).to respond_to :uworks_recent
        expect(cp.uworks_recent).to be_instance_of Array
      end
      it 'retourne aucun élément' do
        expect(cp.uworks_recent.count).to eq 0
      end
    end
    describe '#aworks_ofday' do
      it 'répond et retourne une liste' do
        expect(cp).to respond_to :aworks_ofday
        expect(cp.aworks_ofday).to be_instance_of Array
      end
      it 'retourne un élément' do
        expect(cp.aworks_ofday.count).to eq 1
      end
    end
    describe '#uworks_overrun' do
      it 'répond et retourne une liste' do
        expect(cp).to respond_to :uworks_overrun
        expect(cp.uworks_overrun).to be_instance_of Array
      end
      it 'retourne aucun élément' do
        expect(cp.uworks_overrun.count).to eq 0
      end
    end
  end


  context 'Un autre au deuxième jour du programme' do
    before(:all) do
      prepare_auteur( auteur_id: @up.id, pday: 2 )
      @cp = @up.current_pday
      # On calcule ici les valeurs
      # TODO
    end
    it '#aworks_until_today retourne au moins 5 works' do
      expect(cp.aworks_until_today.count).to be >= 5
    end
    it '#aworks_unstarted doit retourner au moins 1 work' do
      expect(cp.aworks_unstarted.count).to be >= 1
    end
    it '#aworks_ofday doit retourner au moins 4 travaux' do
      expect(cp.aworks_ofday.count).to be >= 4
    end
  end
end
