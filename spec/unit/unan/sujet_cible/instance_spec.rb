describe 'Instance Unan::SujetCible' do
  before(:all) do
    site.require_objet 'unan'
    Usc = Unan::SujetCible

    @sc = Usc::new(:projet, :presentation)
  end

  let(:sc) { @sc }

  # Initialize
  describe 'Initialisation' do
    context 'sans argument' do
      it 'produit une erreur d’argument' do
        expect{Usc::new}.to raise_error ArgumentError
      end
    end
    context 'avec un seul argument de type nombre de 0 à 9' do
      it 'produit une erreur d’argument' do
        expect{Usc::new( 8 )}.to raise_error ArgumentError
      end
    end
    context 'avec un argument seul (de type "<val sujet><val sub-sujet>")' do
      it 'retourne une instance Unan::SujetCible' do
        expect(Usc::new("00")).to be_instance_of Usc
      end
    end
    context 'avec un double argument de type val-sujet, val-subsujet' do
      it 'retourne une instance Unan::SujetCible' do
        res = Usc::new(1, 0)
        expect(res).to be_instance_of Usc
        expect(res.human_name).not_to eq nil # => existe
      end
    end
    context 'avec un double argument de type symbol et valeur' do
      it 'retourne une instance existante' do
        res = Usc::new(:projet, 2)
        expect(res).to be_instance_of Usc
        expect(res.human_name).not_to eq nil # => existe
      end
    end
    context 'avec un double argument de type symbol et symbol' do
      it 'retourne une instance existante' do
        res = Usc::new(:projet, :presentation)
        expect(res).to be_instance_of Usc
        expect(res.human_name).not_to eq nil # => existe
      end
    end
  end

  describe '#sujet_id' do
    it 'répond' do
      expect(sc).to respond_to :sujet_id
    end
    it 'retourne l’identifiant Symbol du sujet' do
      expect(sc.sujet_id).to be_instance_of Symbol
    end
    it 'retourne la bonne valeur' do
      {
        "00"  => :none,
        "1-"  => :projet,
        "21"  => :histoire,
        "32"  => :personnage
      }.each do |args, expected|
        expect(Usc::new(args).sujet_id).to eq expected
      end
    end
  end

  describe 'sub_sujet_id' do
    it 'répond' do
      expect(sc).to respond_to :sub_sujet_id
    end
    it 'retourne l’identifiant du sujet sujet lorsqu’il est défini' do
      {
        "00"  => :none,
        "10"  => :informations,
        "21"  => :pitch
      }.each do |args, expected|
        expect(Usc::new(args).sub_sujet_id).to eq expected
      end
    end
    it 'retourne nil lorsqu’aucun sous-sujet n’est défini ("-")' do
      expect(Usc::new("4-").sub_sujet_id).to eq nil
    end
  end

  describe '#human_name' do
    it 'répond' do
      expect(sc).to respond_to :human_name
    end
    it 'retourne le nom humain du sujet cible' do
      expect(sc.human_name).to be_instance_of String
    end
    it 'retourne le bon nom humain' do
      {
        "0-"  => "Aucun",
        "00"  => "Aucun::Aucun",
        "1-"  => "Projet",
        "11"  => "Projet::Présentation",
        "32"  => "Personnage::Dialogue"
      }.each do |args, expected|
        expect(Usc::new(args).human_name).to eq expected
      end
    end
  end
end
