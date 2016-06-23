=begin

  Module pour tester les méthodes de bilan avec des travaux
  qui sont en retard

=end
describe 'Avec des travaux en retard' do
  before(:all) do
    # Librairies requises
    site.require_objet 'unan'
    Unan.require_module('user/current_pday')

    # Gros travail de préparation
    prepare_auteur( pday: 10 )

  end

  let(:up) { User.new(@auteur_id) }

  # ---------------------------------------------------------------------
  #   Les travaux achevés
  # ---------------------------------------------------------------------
  describe 'uworks_done' do
    it 'répond et retourne une liste de travaux' do
      expect(up.current_pday).to respond_to :uworks_done
      res = up.current_pday.uworks_done
      expect(res).to be_instance_of Array
      expect(res).not_to be_empty
      premier = res.first
      expect(premier).to be_instance_of Hash
    end
    it 'doit avoir le bon nombre de travaux' do
      expect(up.current_pday.uworks_done.count).to eq up.table_works.count(where: {status: 9, program_id: @program_id})
    end
    describe 'un élément de uworks_done est un hash contenant' do
      before(:all) do
        @h = @up.current_pday.uworks_done.first
      end
      let(:h) { @h }
      it ':pday, le jour-programme du travail' do
        expect(h).to have_key :pday
        expect(h[:pday]).not_to eq nil
        expect(h[:pday]).to be > 0
        expect(h[:pday]).to be <= 10
      end
      it ':awork_id, l’identifiant du travail absolu' do
        expect(h).to have_key :awork_id
        expect(h[:awork_id]).not_to eq nil
      end
      it ':uwork_id, l’identifiant du travail de l’auteur' do
        expect(h).to have_key :uwork_id
        expect(h[:uwork_id]).not_to eq nil
      end
      it ':status, le statut actuel du travail' do
        expect(h).to have_key :status
        expect(h[:status]).to eq 9
      end
    end
  end


  # ---------------------------------------------------------------------
  #   La liste des identifiants relatifs de travaux
  #   achevés
  # ---------------------------------------------------------------------
  # Pour rappel, cette liste est un hash qui contient en
  # valeur {:awork_id, uwork_id, :pday} et en clé un identifiant composé
  # de "<abs work id>-<pday du work>"
  describe 'auworks_done_ids' do
    it 'répond et retourne une liste de hash' do
      expect(up.current_pday).to respond_to :auworks_done_ids
      res = up.current_pday.auworks_done_ids
      expect(res).to be_instance_of Hash
      premier = res.values.first
      expect(premier).to be_instance_of Hash
      expect(premier).to have_key :awork_id
      expect(premier).to have_key :uwork_id
      expect(premier).to have_key :pday
    end
    it 'définit un élément conforme par travail achevé' do
      res = up.current_pday.auworks_done_ids
      up.table_works.select(where: {status: 9}).each do |hw|
        abs_work_id = hw[:abs_work_id]
        abs_pday    = hw[:abs_pday] || raise("Le travail devrait définir son jour-programme.")
        wkey = "#{abs_work_id}-#{abs_pday}"
        expect(res).to have_key wkey
        item = res[wkey]
        {
          awork_id: abs_work_id,
          uwork_id: hw[:id],
          pday:     abs_pday
        }.each do |k, v|
          expect(item).to have_key(k)
          expect(item[k]).to eq v
        end
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Travaux non fini (en cours)
  # ---------------------------------------------------------------------
  describe 'uworks_undone' do
    it 'répond et retourne une liste de hash' do
      expect(up.current_pday).to respond_to :uworks_undone
      res = up.current_pday.uworks_undone
      expect(res).to be_instance_of Array
      expect(res.first).to be_instance_of Hash
    end
    it 'renvoie le bon nombre d’éléments' do
      expect(up.current_pday.uworks_undone.count).to eq up.table_works.count(where: "program_id = #{@program_id} AND status < 9")
    end
    describe 'un élément de uworks_undone contient la propriété…' do
      before(:all) do
        @h = @up.current_pday.uworks_undone.first
      end
      let(:h) { @h }
      it ':awork_id, l’id du travail absolu' do
        expect(h).to have_key :awork_id
        expect(h[:awork_id]).not_to eq nil
      end
      it ':uwork_id, l’id du travail de l’auteur' do
        expect(h).to have_key :uwork_id
        expect(h[:uwork_id]).not_to eq nil
      end
      it ':pday, le jour-programme du travail' do
        expect(h).to have_key :pday
        expect(h[:pday]).not_to eq nil
        expect(h[:pday]).to be > 0
        expect(h[:pday]).to be <= 10
      end
      it ':status, le statut actuel du travail' do
        expect(h).to have_key :status
        expect(h[:status]).to be < 9
      end
    end

  end

  # ---------------------------------------------------------------------
  #   Travaux en dépassement
  # ---------------------------------------------------------------------
  describe 'uworks_overrun' do
    it 'répond et retourne une liste de hash' do
      expect(up.current_pday).to respond_to :uworks_overrun
      res = up.current_pday.uworks_overrun
      expect(res).to be_instance_of Array
      premier = res.first
      expect(premier).to be_instance_of Hash
    end
    it 'ne contient que des travaux en dépassement' do
      up.current_pday.uworks_overrun.each do |hw|
        expect(hw[:overrun]).to be > 0
        expect(hw[:pday] + hw[:duree]).to be < 10
      end
    end
    describe 'chaque élément de uworks_overrun contient…' do
      before(:all) do
        @h = @up.current_pday.uworks_overrun.first
        puts "@h : #{@h.inspect}"
      end
      let(:h) { @h }
      it ':overrun, le nombre de jours de dépassement' do
        expect(h).to have_key :overrun
        expect(h[:overrun]).not_to eq nil
        expect(h[:overrun]).to be > 0
      end
      it ':awork_id, l’identifiant du travail absolu' do
        expect(h).to have_key :awork_id
        expect(h[:awork_id]).not_to eq nil
      end
      it ':uwork_id, l’identifiant du travail de l’auteur' do
        expect(h).to have_key :uwork_id
        expect(h[:uwork_id]).not_to eq nil
      end
      it ':pday, le jour-programme du travail' do
        expect(h).to have_key :pday
        expect(h[:pday]).not_to eq nil
        expect(h[:pday]).to be > 0
        expect(h[:pday]).to be <= 10
      end
    end
  end
  # ---------------------------------------------------------------------
  #   Les travaux qui se poursuivent
  # ---------------------------------------------------------------------
  describe 'uworks_goon' do
    it 'répond et retourne une liste de travaux' do
      expect(up.current_pday).to respond_to :uworks_goon
      res = up.current_pday.uworks_goon
      expect(res).to be_instance_of Array
      premier = res.first
      expect(premier).not_to eq nil
      expect(premier).to be_instance_of Hash
    end
    it 'ne doit contenir que des travaux en dépassement' do
      up.current_pday.uworks_goon.each do |hw|
        expect(hw[:pday] + hw[:duree]).to be >= 10
      end
    end
    describe 'chaque élément de uworks_goon contient…' do
      before(:all) do
        @h = @up.current_pday.uworks_goon.first
      end
      let(:h) { @h }
      it ':awork_id, l’identifiant du travail absolu' do
        expect(h).to have_key :awork_id
        expect(h[:awork_id]).not_to eq nil
      end
      it ':uwork_id, l’identifiant du travail de l’auteur' do
        expect(h).to have_key :uwork_id
        expect(h[:uwork_id]).not_to eq nil
      end
      it ':pday, le jour-programme du travail' do
        expect(h).to have_key :pday
        expect(h[:pday]).not_to eq nil
        expect(h[:pday]).to be > 0
        expect(h[:pday]).to be <= 10
      end
      it ':reste, le nombre de jours-programme restants' do
        expect(h).to have_key :reste
        expect(h[:reste]).not_to eq nil
        expect(h[:reste]).to be >= 0
      end
    end
    it 'contient la bonne liste des travaux qui se poursuivent' do
      # Les travaux qui se poursuivent sont :
      #   - des travaux démarrés
      #   - qui ne sont pas en dépassement d'échéance
      # Les autres sont en dépassement. Il suffit de les
      # compter pour savoir qu'on les a tous
      overruns = []
      poursuis = []
      @aworks_started.each do |hw|
        reste = (hw[:duree] + hw[:pday]) - 10
        if reste < 0
          overruns << hw
        else
          poursuis << hw
        end
      end

      nb_poursuis_in_method = up.current_pday.uworks_goon.count
      nb_poursuis_in_table  = poursuis.count
      nb_overruns_in_method = up.current_pday.uworks_overrun.count
      nb_overruns_in_table  = overruns.count

      if nb_poursuis_in_method != nb_poursuis_in_table
        puts "\n\nCES DEUX TABLES DEVRAIENT ÊTRE IDENTIQUES"
        puts "up.current_pday.uworks_goon :\n#{up.current_pday.uworks_goon.pretty_inspect}"
        puts "poursuis :\n #{poursuis.pretty_inspect}"
      end

      expect(nb_poursuis_in_method).to eq nb_poursuis_in_table
      expect(nb_overruns_in_table).to eq nb_overruns_in_method
    end
  end

  describe 'uworks_unstarted' do
    it 'répond et retourne un Array de Hash' do
      expect(up.current_pday).to respond_to :uworks_unstarted
      res = up.current_pday.uworks_unstarted
      expect(res).to be_instance_of Array
      expect(res.first).to be_instance_of Hash
    end
    describe 'un élément de uworks_unstarted contient les propriétés' do
      before(:all) do
        @h = @up.current_pday.uworks_unstarted.first
      end
      let(:h) { @h }
      it ':since, le nombre de jours depuis quand le travail aurait dû être démarré' do
        expect(h).to have_key :since
        expect(h[:since]).not_to eq nil
        expect(h[:since]).to eq up.current_pday.day - h[:pday]
      end
    end
  end

end
