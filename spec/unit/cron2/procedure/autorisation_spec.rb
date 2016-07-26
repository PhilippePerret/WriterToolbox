=begin

  Module de test du cron pour checker la procédure checkant
  les autorisations d'accès au site.

=end
describe 'Procédure d’épuration des autorisations' do
  def autotable
    @autotable ||= site.dbm_table(:hot, 'autorisations')
  end
  before(:all) do
    # Dans un premier temps, on va détruire toutes les
    # autorisations, en récupérant celles qui existent pour
    # pouvoir les remettre ensuite
    tbl = User.table_autorisations
    @all_autorisations = tbl.select
    tbl.delete
    expect(tbl.count).to eq 0
    #
    # Il faut requérir les librairies du cron, mais sans
    # lancer la procédure de test
    CRON_FOR_TEST = true
    require './CRON2/run'
    SuperFile.new('./CRON2/lib/procedure/autorisations').require

    @u = create_user

  end

  after(:all) do
    # À la fin, on remet toutes les autorisations (pour le moment,
    # on se content de remettre celles de Benoit)
    @all_autorisations.each do |dauto|
      dauto[:user_id] == 2 || next
      User.table_autorisations.insert(dauto)
    end
  end

  let(:cron) { CRON2.instance }

  # CRON2#autorisations
  describe 'La méthode CRON2#autorisations' do
    it 'répond à autorisations' do
      expect(cron).to respond_to :autorisations
    end
    it 'appelle la méthode CRON2::Autorisations::check_autorisations' do
      allow_any_instance_of(CRON2::Autorisations).to receive(:check_autorisations){'ON PASSE PAR CHECK_AUTORISATIONS'}
      res = cron.autorisations
      expect(res).to eq 'ON PASSE PAR CHECK_AUTORISATIONS'
    end
  end

  describe 'Destruction d’une autorisation dépassée' do
    before(:each) do
      reset_mails
      if @id_new_auto.nil? || User.table_autorisations.get(@id_new_auto).nil?
        dauto = {
          user_id:      @u.id,
          raison:       'ABONNEMENT',
          start_time:   NOW - 1.year - 1.hour,
          end_time:     NOW - 1.hour,
          created_at:   NOW,
          updated_at:   NOW
        }
        @id_new_auto = User.table_autorisations.insert(dauto)
      end
      @count_autos_init = User.table_autorisations.count
    end
    it 'une autorisation dépassée est détruite' do
      drequest = {where: "id = #{@id_new_auto}"}
      expect(autotable.count(drequest)).to eq 1
      cron.autorisations
      expect(autotable.count).to eq @count_autos_init - 1
      expect(autotable.count(drequest)).to eq 0
    end
    it 'une autorisation terminée dans 3 jours lance un mail' do
      start_time = Time.now.to_i - 1
      autotable.update(@id_new_auto, {end_time: NOW + 3.days - 4.hours})
      # --- On traite les autorisations ---
      cron.autorisations
      expect(@u).to have_mail(
        sent_after:   start_time,
        subject:      'État de votre abonnement',
        message:      ['moins de trois jours']
      )
      # L'autorisation n'a pas été supprimée
      expect(autotable.count(where:{id: @id_new_auto})).to eq 1
    end
    it 'une autorisation qui se termine dans une semaine lance un mail conforme' do
      start_time = Time.now.to_i - 1
      autotable.update(@id_new_auto, {end_time: NOW + 1.week - 4.hours})
      cron.autorisations
      expect(@u).to have_mail(
        sent_after:   start_time,
        subject:      'État de votre abonnement',
        message:      ['moins d’une semaine']
      )
      # L'autorisation n'a pas été supprimée
      expect(autotable.count(where:{id: @id_new_auto})).to eq 1
    end
    it 'une autorisation qui se termine dans trois semaines quand elle a durée moins de 30 semaines ne génère par de mail' do
      # Je ne sais pas pourquoi, mais ici, je suis obligé de
      # créer une nouvelle autorisation, sinon, c'est la précédente
      # qui est considérée (alors que toutes les variables d'instance
      # sont resetée, en tout cas il me semble…)
      reset_mails
      autotable.delete
      dauto = {
        user_id: @u.id,
        raison:  'JOURS CADEAUX',
        start_time: NOW - 5.weeks,
        end_time:   NOW + 3.week - 4.hours,
        created_at: NOW,
        updated_at: NOW
      }
      start_time = Time.now.to_i - 1
      autotable.insert(dauto)
      cron.autorisations
      expect(@u).not_to have_mail(
        sent_after:   start_time,
        subject:      'État de votre abonnement'
      )
    end
    it 'une autorisation qui se termine dans trois semaines quand elle a duré plus de 30 semaines génère un mail d’avertissement' do
      start_time = Time.now.to_i - 1
      autotable.update(@id_new_auto, {
          start_time: NOW - 1.year,
          end_time: NOW + 3.week - 4.hours
        })

      cron.autorisations

      expect(@u).to have_mail(
        sent_after:   start_time,
        subject:      'État de votre abonnement',
        message:      ['moins de trois semaines']
      )
      # L'autorisation n'a pas été supprimée
      expect(autotable.count(where:{id: @id_new_auto})).to eq 1
    end
  end


  describe 'Création du ticket lorsqu’un user arrive à expiration' do
    before(:all) do
      reset_mails
      @start = Time.now.to_i - 1
      autotable.delete
      @idauto = autotable.insert({
          user_id:        @u.id,
          raison:         'ABONNEMENT',
          start_time:     NOW - 1.year,
          end_time:       NOW - 2.hours,
          nombre_jours:   365,
          privileges:     nil,
          created_at:     NOW,
          updated_at:     NOW
        })
      expect(autotable.count).to eq 1

      # ===========> TEST <===========
      CRON2.instance.autorisations

    end # Fin du before :all

    it 'l’autorisation a été détruite' do
      expect(autotable.get(@idauto)).to eq nil
      expect(autotable.count).to eq 0
    end
    it 'un ticket a été créé' do
      # On récupère le mail pour récupérer le numéro du ticket
      dmail = nil
      Dir['./tmp/mails/*.msh'].each do |pmail|
        dmail = File.open(pmail,'rb'){|f| Marshal.load(f.read)}
      end
      tout, ticket_id = dmail[:message].match(/tckid=(.*?)"/).to_a
      table = site.dbm_table(:hot, 'tickets')
      dticket = table.get(where: {id: ticket_id})
      expect(dticket).not_to eq nil
      expect(dticket[:code]).to eq "User.new(#{@u.id}).autologin(route:'user/paiement')"
    end

  end
end
