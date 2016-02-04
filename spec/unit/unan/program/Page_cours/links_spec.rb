=begin
Test des méthodes de liens
=end

site.require_objet 'unan'
describe 'Méthodes de liens de Unan::Program::PageCours' do
  before(:all) do
    @page_id    = 1
    @pagecours  = page_cours(@page_id)
  end
  let(:pagecours) { @pagecours }
  describe '#link' do
    it 'répond' do
      expect(pagecours).to respond_to :link
    end
    context 'sans option' do
      it 'retourne un lien valide vers la page de cours à afficher' do
        res = pagecours.link
        expect(res).to have_tag 'a', with: {href:"page_cours/#{@page_id}/show?in=unan"}
      end
    end
    context 'avec un titre forcé' do
      it 'retourne le lien avec le titre voulu' do
        res = pagecours.link titre: "Mon titre"
        expect(res).to have_tag 'a', with: {href:"page_cours/#{@page_id}/show?in=unan"}, text: "Mon titre"
      end
    end
    context 'avec l’option :edit à true' do
      it 'retourne le lien d’édition' do
        res = pagecours.link edit: true
        expect(res).to have_tag 'a', with: {href:"page_cours/#{@page_id}/edit?in=unan_admin"}
      end
    end
    context 'avec l’option :delete à true' do
      it 'retourne le lien de destruction' do
        res = pagecours.link delete: true
        expect(res).to have_tag 'a', with: {href:"page_cours/#{@page_id}/destroy?in=unan_admin"}
      end
    end
  end
  describe '#lien (alias de #link)' do
    it 'répond' do
      expect(pagecours).to respond_to :lien
    end
  end

end
