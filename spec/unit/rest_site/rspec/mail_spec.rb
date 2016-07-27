# encoding: UTF-8
=begin
  Pour tester la classe MailMatcher qui teste les mails
=end

describe 'MailMatcher' do
  before(:all) do
    @u = User.new User.table_users.select(where:'CAST(SUBSTRING(options,1,1) AS UNSIGNED) > 2', colonnes:[]).first[:id]
    @u2 = User.new User.table.select(where: "id != #{@u.id}").first[:id]
    @u3 = User.new User.table.select(where: "id NOT IN (#{@u.id}, #{@u2.id})").first[:id]
  end
  describe 'Simple recherche d’un mail à un user sans condition' do
    before(:each) do
      remove_mails
      @u2.send_mail(sujet: "Sujet à u2", message: "message à u2")
      @u3.send_mail(sujet: "Sujet à u3", message: "message à u3")
    end
    context 'avec un mail existant' do
      before(:each) do
        @u.send_mail(subject: "Sujet", message: "Un message")
      end
      it 'contient 3 mails' do
        expect(MailMatcher.nombre_mails).to eq 3
      end
      it 'réussit' do
        expect(@u).to have_mail
      end
    end
    context 'sans mail existant' do
      it 'échoue' do
        remove_mails
        expect(@u).not_to have_mail
      end
    end
  end

  describe 'Recherche de mail par le sujet et le message' do
    before(:all) do
      remove_mails

      # Message à U pour le sujet
      @sujet_u = "Sujet pour u à #{Time.now}"
      @u.send_mail(subject: @sujet_u, message: "Un message quelconque")

      # Message à U2 pour le message
      @date_message_u2 = Time.now.to_s # pour message partiel
      @message_u2 = "Message pour u2 envoyé à #{@date_message_u2}"
      @message_partiel_u2 = "sage pour u2 envoyé"
      @u2.send_mail(subject: 'Sujet à u2 ', message: @message_u2)
    end
    context 'avec un string exact' do
      it 'réussit' do
        expect(@u).to have_mail(subject: @sujet_u)
      end
    end
    context 'avec un string partiel (mais recherche non stricte)' do
      it 'réussit' do
        expect(@u).to have_mail(subject: "Sujet pour u ")
      end
    end
    context 'avec un string partiel et strict' do
      it 'échoue' do
        expect(@u).not_to have_mail(subject: "Sujet pour u ", subject_strict: true)
      end
    end

    # ---------------------------------------------------------------------
    #   Message

    context 'avec un string complet et recherche non stricte' do
      it 'réussit' do
        expect(@u2).to have_mail(:message => @message_u2)
      end
    end
    context 'avec string complet et recherche stricte' do
      it 'réussit' do
        expect(@u2).to have_mail(message: @message_u2, message_strict: true)
      end
    end
    context 'avec un string partiel et une recherche non stricte' do
      it 'réussit avec un segment valide' do
        expect(@u2).to have_mail(message: @message_partiel_u2)
      end
      it 'échoue avec un mauvais segment' do
        expect(@u2).not_to have_mail(message: 'mauvais segment')
      end
    end
    context 'avec un string partiel et une recherche stricte' do
      it 'échoue' do
        expect(@u2).not_to have_mail(
          message_strict: true,
          message:        @message_partiel_u2
          )
      end
    end
    context 'avec plusieurs strings partiels et une recherche non stricte' do
      it 'réussit avec les bons segmets' do
        expect(@u2).to have_mail(
          message: [@message_partiel_u2, @date_message_u2]
        )
      end
      it 'échoue avec un mauvais segment' do
        expect(@u2).not_to have_mail(
          message: [@message_partiel_u2, 'mauvais segment']
        )
      end
    end
  end

  describe 'Recherche de mails par la date' do
    before(:all) do
      remove_mails
      @start_time = Time.now.to_i.freeze


      sleep 2
      # Message à U pour le sujet
      @sujet_u = "Sujet pour u à #{Time.now}"
      @u.send_mail(subject: @sujet_u, message: "Un message quelconque")

      # Message à U2 pour le message
      @date_message_u2 = Time.now.to_s # pour message partiel
      @message_u2 = "Message pour u2 envoyé à #{@date_message_u2}"
      @message_partiel_u2 = "sage pour u2 envoyé"

      @u2.send_mail(subject: 'Sujet à u2 ', message: @message_u2)
    end

    context 'avec une date correspondant à la recherche :sent_after' do
      it 'réussit' do
        expect(@u).to have_mail(sent_after: @start_time - 2)
      end
    end
    context 'avec une date correspondant à la recherche :sent_before' do
      it 'réussit' do
        expect(@u).to have_mail(sent_before: @start_time + 60)
      end
    end
    context 'avec une recherche de date avant' do
      it 'échoue' do
        expect(@u).not_to have_mail(sent_after: @start_time + 10)
      end
    end
    context 'avec une recherche de date après' do
      it 'échoue' do
        expect(@u).not_to have_mail(sent_before: @start_time - 2)
      end
    end
  end
end
