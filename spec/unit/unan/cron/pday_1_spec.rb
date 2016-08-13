=begin

  Test du travail du CRON job pour un auteur qui passe au
  second jour

=end
require_relative '_required'

describe 'Cron job, pour le premier jour' do
  before(:all) do
    benoit.set_auteur_unanunscript(pday: 1, verbose: true)
  end
  describe 'Vérifications préliminaires' do
    it 'benoit est bien un auteur du programme UNAN' do
      expect(benoit).to be_unanunscript
    end
    it 'Benoit est bien à son premier jour' do
      expect(benoit.program.current_pday).to eq 1
    end
  end

  describe 'Déclenchement du CRON' do
    it 'Benoit ne reçoit pas de mail à son premier jour quand le cron est lancé' do
      remove_mails
      start_time = NOW - 1
      require './CRON2/run'
      benoit.napas_recu_le_mail(
        sent_after: start_time
      )
    end
    it 'Benoit reçoit un mail si l’heure courante est supérieur à la date de prochain jour-programme' do
      remove_mails
      start_time = NOW - 1
      require './CRON2/run'
      benoit.a_recu_le_mail(
        sent_after: start_time
      )
    end
  end
end
