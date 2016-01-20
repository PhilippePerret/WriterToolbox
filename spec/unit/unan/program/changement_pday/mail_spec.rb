describe 'Gestion des mails au cours du changement de P-Day' do

  def init_all_variables

  end
  before(:all) do
    site.require_objet 'unan'
    Unan::require_module "start_pday"
    @program  = get_any_program
    @starter  = Unan::Program::StarterPDay::new @program
  end
  let(:auteur) { @program.auteur }
  let(:program) { @program }
  let(:starter) { @starter }
  describe '#mail_auteur' do
    it 'répond' do
      expect(starter).to respond_to :mail_auteur
    end
    it 'retourne une instance Unan::Program::StarterPDay::MailAuteur' do
      expect(starter.mail_auteur).to be_instance_of Unan::Program::StarterPDay::MailAuteur
    end
  end

  describe 'méthodes de MailAuteur' do
    before(:all) do
      @mailauteur = @starter.mail_auteur
    end
    let(:mailauteur) { @mailauteur }
    describe '#introduction' do
      it 'répond' do
        expect(mailauteur).to respond_to :introduction
      end
      it 'retourne une instance ::Section' do
        expect(mailauteur.introduction).to be_instance_of Unan::Program::StarterPDay::MailAuteur::Section
      end
      it 'répond à <<' do
        expect(mailauteur.introduction).to respond_to :<<
      end
    end
    describe '#travaux_courants' do
      it 'répond' do
        expect(mailauteur).to respond_to :travaux_courants
      end
      it 'retourne une instance ::Section' do
        expect(mailauteur.travaux_courants).to be_instance_of Unan::Program::StarterPDay::MailAuteur::Section
      end
      it 'répond à <<' do
        expect(mailauteur.travaux_courants).to respond_to :<<
      end
    end
    describe '#nouveaux_travaux' do
      it 'répond' do
        expect(mailauteur).to respond_to :nouveaux_travaux
      end
      it 'retourne une instance ::Section' do
        expect(mailauteur.nouveaux_travaux).to be_instance_of Unan::Program::StarterPDay::MailAuteur::Section
      end
      it 'répond à <<' do
      expect(mailauteur.nouveaux_travaux).to respond_to :<<
    end
  end
    describe '#conclusion' do
      it 'répond' do
        expect(mailauteur).to respond_to :conclusion
      end
      it 'retourne une instance ::Section' do
        expect(mailauteur.conclusion).to be_instance_of Unan::Program::StarterPDay::MailAuteur::Section
      end
      it 'répond à <<' do
        expect(mailauteur.conclusion).to respond_to :<<
      end
      it '<< permet d’ajouter du texte' do
        init  = "#{mailauteur.conclusion.content}"
        str   = "Du texte à #{Time.now}"
        mailauteur.conclusion << str
        expect(mailauteur.conclusion.content).to eq "#{init}#{str}"
      end
    end


    describe '#motif_reception_mail' do
      it 'répond' do
        expect(mailauteur).to respond_to :motif_reception_mail
      end
      context 'pour un auteur voulant un mail quotidien' do
        before(:all) do
          init_all_variables
          @program.auteur.instance_variable_set('@has_daily_summary', true)
        end
        it 'le message est conforme à cette demande' do
          res = mailauteur.motif_reception_mail
          expect(res).to match "vous désirez recevoir un rapport journalier"
          expect(res).to match "votre bureau"
        end
      end
      context 'pour un auteur ne voulant pas de mail quotidien' do
        before(:all) do
          init_all_variables
          @program.auteur.instance_variable_set('@has_daily_summary', false)
        end
        it 'le message est conforme à cette demande' do
          res = mailauteur.motif_reception_mail
          expect(res).to match "vous désirez ne recevoir des messages"
          expect(res).to match "que lorsque de nouveaux travaux sont demandés"
          expect(res).to match "votre bureau"
        end
      end
    end

    describe '#send_mail' do
      before(:all) do
        @start_time = Time.now.to_i - 10
      end
      it 'répond' do
        expect(mailauteur).to respond_to :send_mail
      end
      it 'envoie le mail à l’auteur' do
        mailauteur.send_mail
        expect(auteur).to have_mail_with(
          sent_after:   @start_time,
          subject:      "Rapport journalier du #{NOW.as_human_date}"
        )
      end
    end

  end


end
