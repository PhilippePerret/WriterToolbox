=begin

  Module unitaire principal de test des Comments

  Rappel : Comments et une classe liée à Page
  Page::Comments

=end
describe 'Comments' do

  # enable_comments
  it 'la méthode enable_comments répond' do
    expect{send(:enable_comments)}.not_to raise_error
  end

  # page#comments?
  describe 'Méthode page#comments?' do
    it 'répond' do
      expect(page).to respond_to :comments?
    end
    context 'avec les commentaires activés' do
      it 'retourne true' do
        enable_comments
        expect(page.comments?).to eq true
      end
    end
    context 'avec les commentaires désactivés' do
      it 'retourne false' do
        unable_comments
        expect(page.comments?).to eq false
      end
    end
  end

  # page.comments
  describe 'Méthode page#comments' do
    it 'répond' do
      expect(page).to respond_to :comments
    end
    it 'retourne la section des commentaires (page_comments)' do
      code = page.comments
      expect(code).to have_tag('section#page_comments')
    end
  end
end
