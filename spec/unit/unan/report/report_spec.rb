=begin

  Module de test du message envoyé à l'auteur

=end
describe 'Mail envoyé à l’auteur inscrit au programme UN AN UN SCRIPT' do
  before(:all) do
    site.require_objet 'unan'
    Unan.require_module 'user/current_pday'
  end

  def write_report_in fname, report
    fpath = SuperFile::new("./tmp/rspec/#{fname}")
    fpath.remove if fpath.exist?
    fpath.write <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta http-equiv="Content-type" content="text/html; charset=utf-8">
      <title>Mail</title>
    </head>
    <body>#{report}</body></html>
    HTML
    puts "Rapport écrit dans #{fpath}"
  end

  context 'Pour un auteur qui a un peu de tout' do
    before(:all) do
      prepare_auteur( pday: 10, done_upto: 4 )
      @up.program.set rythme: 6
    end
    let(:up) { @up }
    it 'auteur est défini' do
      expect(up).not_to eq nil
      expect(up).to be_instance_of User
    end

    describe '#rapport_complet' do
      before(:all) do
        @report = @up.current_pday.rapport_complet
        write_report_in("avec_depassements.html", @report)
      end
      let(:report) { @report }
      it 'répond et retourne un String' do
        expect(up.current_pday).to respond_to :rapport_complet
        expect(up.current_pday.rapport_complet).to be_instance_of String
      end
      it 'contient l’invite avec le pseudo de l’auteur' do
        expect(report).to include "Bonjour #{up.pseudo}"
      end
      it 'contient le cadre chiffré' do
        expect(report).to have_tag('div#cadre_chiffres')
      end
      it 'le cadre chiffré contient le nombre de points' do
        expect(report).to have_tag('div#cadre_chiffres') do
          with_tag 'span#nombre_points', text: up.program.points
        end
      end
      it 'le cadre chiffré contient l’indice du jour-programme' do
        expect(report).to have_tag('div#cadre_chiffres') do
          with_tag 'span#jour_programme', text: up.program.current_pday
        end
      end
      it 'le cadre chiffré contient la note générale' do
        expect(report).to have_tag('div#cadre_chiffres') do
          with_tag 'span#note_generale', text: /#{Regexp.escape up.current_pday.note_generale.to_s}/
        end
      end
      it 'contient le message général' do
        expect(report).to have_tag('div#message_general')
      end
      it 'contient une section pour l’inventaire' do
        expect(report).to have_tag('section#unan_inventory')
      end

      it 'contient le fieldset des nouveaux travaux' do
        expect(report).to have_tag('fieldset#fs_new_works')
      end
      it 'le fieldset des nouveaux travaux contient la bonne légende' do
        nb = up.current_pday.uworks_ofday.count
        expect(report).to have_tag('fieldset#fs_new_works') do
          with_tag 'legend', text: "Nouveaux travaux (#{nb})"
        end
      end
      it 'le fieldset des nouveaux travaux contient le texte explicatif' do
        expect(report).to have_tag('fieldset#fs_new_works') do
          with_tag 'div.explication', text: /des nouveaux travaux/
        end
      end
      it 'le fieldset des nouveaux travaux liste tous les nouveaux travaux' do
        expect(report).to have_tag('fieldset#fs_new_works') do
          up.current_pday.uworks_ofday.each do |hw|
            titre = Unan.table_absolute_works.get(hw[:awork_id])[:titre].strip_tags
            with_tag 'li.work', text: /#{Regexp.escape titre}/
          end
        end
      end

      it 'contient le fieldset des travaux en dépassement' do
        expect(report).to have_tag('fieldset#fs_works_overrun')
      end
      it 'le fieldset des dépassements contient la bonne légende' do
        nb = up.current_pday.uworks_overrun.count
        expect(report).to have_tag('fieldset#fs_works_overrun') do
          with_tag 'legend', text: "Travaux en dépassement (#{nb})"
        end
      end
      it 'le fieldset des dépassements contient un div d’explication' do
        expect(report).to have_tag('fieldset#fs_works_overrun') do
          with_tag 'div.explication', text: /en dépassement d'échéance/
        end
      end
      it 'contient un item pour chaque travail en dépassement' do
        up.current_pday.uworks_overrun.each do |uw|
          awork = Unan.table_absolute_works.get(uw[:awork_id])
          titre = awork[:titre]
          expect(report).to have_tag('fieldset#fs_works_overrun') do
            with_tag 'li', text: /#{Regexp.escape titre}/
          end
        end
      end
      it 'contient le fieldset des travaux à démarrer' do
        expect(report).to have_tag('fieldset#fs_works_unstarted')
      end
      it 'le fieldset des travaux à démarrer contient son texte explicatif' do
        expect(report).to have_tag('fieldset#fs_works_unstarted') do
          with_tag 'div.explication', text: /être démarrés/
        end
      end
      it 'contient une ligne par travaux à démarrer' do
        expect(report).to have_tag('fieldset#fs_works_unstarted') do
          up.current_pday.uworks_unstarted.each do |uw|
            titre = Unan.table_absolute_works.get(uw[:awork_id])[:titre].strip_tags
            with_tag 'li', text: /#{Regexp.escape titre}/
          end
        end
      end
      it 'contient le fieldset des travaux qui se poursuivent' do
        expect(report).to have_tag('fieldset#fs_poursuivis')
      end
      it 'le fieldset des travaux poursuivis possède sa bonne légende' do
        nb = up.current_pday.uworks_goon.count
        expect(report).to have_tag('fieldset#fs_poursuivis') do
          with_tag 'legend', text: "Travaux poursuivis (#{nb})"
        end
      end
      it 'le fieldset des travaux poursuivis contient son div d’explication' do
        expect(report).to have_tag('fieldset#fs_poursuivis') do
          with_tag 'div.explication', text: /à poursuivre/
        end
      end
      it 'le fieldset des travaux poursuivis contient sa liste de travaux' do
        expect(report).to have_tag('fieldset#fs_poursuivis') do
          up.current_pday.uworks_goon.each do |uw|
            titre = Unan.table_absolute_works.get(uw[:awork_id])[:titre].strip_tags
            with_tag 'li.work', text: /#{Regexp.escape titre}/
          end
        end
      end
      it 'contient le fieldset des liens utiles' do
        expect(report).to have_tag('fieldset#fs_liens_utiles')
      end
    end
  end

  context 'Pour un auteur qui n’a aucun dépassement' do
    before(:all) do
      prepare_auteur( pday: 10, done_upto: 10 )
      @report = @up.current_pday.rapport_complet
      write_report_in("sans_depassements.html", @report)
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
