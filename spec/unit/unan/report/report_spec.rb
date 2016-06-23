=begin

  Module de test du message envoyé à l'auteur

=end
describe 'Mail envoyé à l’auteur inscrit au programme UN AN UN SCRIPT' do
  before(:all) do
    site.require_objet 'unan'
    Unan.require_module 'user/current_pday'
  end

  context 'Pour un auteur qui a un peu de tout' do
    before(:all) do
      prepare_auteur( pday: 10 )
    end
    let(:up) { @up }
    it 'auteur est défini' do
      expect(up).not_to eq nil
      expect(up).to be_instance_of User
    end

    describe '#report' do
      before(:all) do
        @report = @up.current_pday.report
      end
      let(:report) { @report }
      it 'répond et retourne un String' do
        expect(up.current_pday).to respond_to :report
        expect(up.current_pday.report).to be_instance_of String
      end
      it 'contient l’invite avec le pseudo de l’auteur' do
        expect(report).to include "Bonjour #{up.pseudo}"
      end
      it 'contient une section pour l’inventaire' do
        expect(report).to have_tag('section#unan_inventory')
      end

      it 'contient le fieldset des travaux en dépassement' do
        expect(report).to have_tag('fieldset#fs_works_overrun')
      end
      it 'contient le fieldset des travaux à démarrer' do
        expect(report).to have_tag('fieldset#fs_works_unstarted')
      end
      it 'contient le fieldset des liens utiles' do
        expect(report).to have_tag('fieldset#fs_liens_utiles')
      end
    end
  end

  context 'Pour un auteur qui n’a aucun dépassement' do
    before(:all) do
      prepare_auteur( pday: 10, done_upto: 9 )
      @report = @up.current_pday.report
    end
    let(:report) { @report }

    it 'ne contient pas le fieldset des travaux en dépassement' do
      expect(report).not_to have_tag('fieldset#fs_works_overrun')
    end
    it 'ne contient pas le fieldset des travaux à démarrer' do
      expect(report).not_to have_tag('fieldset#fs_works_unstarted')
    end
    it 'contient le fieldset des liens utiles' do
      expect(report).to have_tag('fieldset#fs_liens_utiles')
    end

  end
end
