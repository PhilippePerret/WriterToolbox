
site.require_objet 'unan'

describe 'Méthodes de paths de Unan' do

  describe '#folder_data' do
    it 'répond' do
      expect(Unan).to respond_to :folder_data
    end
    it 'retourne un SuperFile' do
      expect(Unan::folder_data).to be_instance_of SuperFile
    end
    it 'avec la bonne valeur' do
      expect(Unan::folder_data.to_s).to eq "./data/unan/data"
    end
  end

  describe '#main_folder_data' do
    it 'répond' do
      expect(Unan).to respond_to :main_folder_data
    end
    it 'retourne un SuperFile' do
      expect(Unan::main_folder_data).to be_instance_of SuperFile
    end
    it 'avec le bon path' do
      expect(Unan::main_folder_data.to_s).to eq "./data/unan"
    end
  end
end
