describe 'Méthodes pour mail du site' do

  describe '::send_mail' do
    it 'répond' do
      expect(site).to respond_to :send_mail
    end
    it 'envoie un mail' do
      datamail = {to: 'benoit.ackerman@yahoo.fr', subject:"Le sujet", message:"Le message", from: "phil@atelier-icare.net"}
      site.send_mail(datamail)
    end
  end
end
