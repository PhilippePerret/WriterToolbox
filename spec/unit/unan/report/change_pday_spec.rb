=begin
  Module pour tester le changement de jour-programme
=end
describe 'Changement de jour-programme' do
  before(:all) do
    site.require_objet 'unan'
    require './CRON/lib/required/UnAnUnScript/User/traite_users.rb'

  end

  # Attention : la méthode plurielle
  describe 'User::traite_users_unanunscript' do
    it 'répond' do
      expect(User).to respond_to :traite_users_unanunscript
    end
  end

  # La méthode pour un user
  describe 'User::traite_program_unanunscript' do
    it 'répond' do
      expect(User).to respond_to :traite_program_unanunscript
    end
    it 'ne produit pas de rapport si non nécessaire' do
      hprog = Unan.table_programs.select(where: 'options LIKE "1%"').first
      hprog != nil || raise("Il faut au moins un programme UN AN UN SCRIPT pour tester ça !")
      prog = Unan::Program.new(hprog[:id])
      prog.set(rythme: 5, current_pday_start: NOW - 6000)
      res = User.traite_program_unanunscript(prog.get_all)
      expect(res).to eq false
    end

    # Test assez complet de l'envoi du rapport :
    #   - Le rapport est envoyé, on test que le jour-programme
    #     a bien été changé et que le mail a été envoyé à
    #     l'auteur.
    #   - Puis on rappelle la méthode, qui ne reproduit pas
    #     de changement de jour-programme
    #
    it 'produit un changement de jour-programme si nécessaire' do
      # Pour choper le message qui doit être transmis
      lemessage = nil
      allow(User).to receive(:log) do |message|
        lemessage = message
      end
      now = Time.now.to_i
      hprog = Unan.table_programs.select(where: 'options LIKE "1%"').first
      hprog != nil || raise("Il faut au moins un programme UN AN UN SCRIPT pour tester ça !")
      auteur = User.new(hprog[:auteur_id])
      prog = Unan::Program.new(hprog[:id])
      prog.set(rythme: 5, current_pday_start: NOW - (1.day + 1))
      res = User.traite_program_unanunscript prog.get_all
      expect(res).to eq true
      expect(lemessage).to include "Auteur ##{auteur.id} (#{auteur.pseudo}) passé au jour-programme #{hprog[:current_pday] + 1}"
      prog = Unan::Program.new(hprog[:id])
      # Le jour programme doit avoir changé
      expect(prog.current_pday).to eq hprog[:current_pday] + 1
      # La date de début doit avoir changé
      expect(prog.current_pday_start).to be_between(now - 10, now + 10)
      # L'auteur doit avoir reçu un mail
      expect(auteur).to have_mail_with(
        subject: /UN AN UN SCRIPT - Rapport journalier/,
        sent_after: now - 1
      )
      # Si on repasse tout de suite par la méthode, elle ne doit pas
      # remodifier le programme
      res = User.traite_program_unanunscript prog.get_all
      expect(res).to eq false
    end
  end
end
