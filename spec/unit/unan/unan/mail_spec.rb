site.require_objet 'unan'
describe 'Envoi des mails' do
  before(:all) do
    @data_valides = {
      to:             'benoit.ackerman@yahoo.fr',
      subject:        "Un sujet de message le #{Time.now}",
      message:        "Un message à envoyer le #{Time.now}",
      force_offline:  false
    }
  end

  describe 'Unan::send_mail' do
    it 'répond' do
      expect(Unan).to respond_to :send_mail
    end
    context 'avec des arguments valides' do
      it 'permet d’envoyer un mail' do
        expect{Unan::send_mail @data_valides}.not_to raise_error
      end
    end
  end
end
