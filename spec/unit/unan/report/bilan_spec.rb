=begin

Module de test du bilan qui permet de faire le mail quotidien
de l'auteur.
Le module qui permet de faire le bilan est un dossier dans
'unan/lib/module', qui doit être chargé.

=end
describe 'Bilan quotidien de l’auteur suivant le programme UN AN UN SCRIPT' do
  before(:all) do
    # On prend un auteur
    @hprog        = site.dbm_table(:unan, 'programs').select.first
    @hprog != nil || raise('Il faut créer un auteur pour le programme UN AN UN SCRIPT')
    @program_id   = @hprog[:id]
    @auteur_id    = @hprog[:auteur_id]
    @up = User.new(@auteur_id)
    site.require_objet 'unan'
    Unan.require_module('user/current_pday')

  end

  let(:up) { User.new(@auteur_id) }

  # ---------------------------------------------------------------------
  #  Quelques vérification préliminaires
  # ---------------------------------------------------------------------
  describe 'L’auteur doit être en programme' do
    it{expect(up).to be_unanunscript}
    it 'il doit être au 4e jour programme' do
      if @hprog[:current_pday] != 4
        up.program.current_pday= 4
      end
      expect(up.current_pday.day).to eq 4
    end
  end

  describe 'uworks_undone' do
    before(:all) do
      # On détruit tous les travaux de l'auteur, pour repartir
      # à zéro
      site.dbm_table(:users_tables, "unan_works_#{@auteur_id}").delete
    end
    it 'répond et retourne une liste de travaux (vide)' do
      expect(up.current_pday).to respond_to :uworks_undone
      expect(up.current_pday.uworks_undone).to be_instance_of Array
      expect(up.current_pday.uworks_undone).to be_empty
    end
  end

  describe 'todays_aworks' do
    it 'répond et retourne une liste de travaux absolus' do
      expect(up.current_pday).to respond_to :todays_aworks
      res = up.current_pday.todays_aworks
      expect(res).to be_instance_of Array
      premier = res.first
      # puts premier.pretty_inspect
    end
    it 'retourne la bonne liste de travaux du jour' do
      res = up.current_pday.todays_aworks
      liste_works_ids = []
      Unan.table_absolute_pdays.select(where: 'id = 4').each do |hpday|
        works_ids = hpday[:works]
        liste_works_ids += works_ids.split(' ').collect{|e| e.to_i}
      end
      expect(res.count).to be > 0
      expect(liste_works_ids.count).to eq res.count
      res.each do |hw|
        expect(liste_works_ids).to include hw[:id]
      end
    end


  end

  describe 'abs_works_until_today' do
    it 'répond et retourne une liste de travaux' do
      expect(up.current_pday).to respond_to :aworks_until_today
      res = up.current_pday.aworks_until_today
      expect(res).to be_instance_of Array
      premier = res.first
      expect(premier).to be_instance_of Hash
    end

    it 'retourne la bonne liste de travaux' do
      res = up.current_pday.aworks_until_today
      liste_works_ids = []
      Unan.table_absolute_pdays.select(where: 'id <= 4').each do |hpday|
        works_ids = hpday[:works]
        liste_works_ids += works_ids.split(' ').collect{|e| e.to_i}
      end
      expect(res.count).to be > 0
      expect(liste_works_ids.count).to eq res.count
      res.each do |hw|
        expect(liste_works_ids).to include hw[:id]
      end
    end

  end

end
