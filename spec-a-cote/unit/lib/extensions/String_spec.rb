describe 'Méthodes d’extension de String' do

  describe '#empty?' do
    it 'répond' do
      expect("subject").to respond_to :empty?
    end
    it 'retourne true si la chaine est vide' do
      expect("").to be_empty
    end
    it 'retourne false si la chaine n’est pas vide' do
      expect("a").not_to be_empty
    end
  end
end
