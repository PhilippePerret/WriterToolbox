describe 'Méthodes pour la gestion des tickets' do

  describe 'table_tickets' do
    it 'répond' do
      expect(app).to respond_to :table_tickets
    end
    it 'retourne une instance de SiteHtml::BDM_TABLE' do
      expect(app.table_tickets).to be_instance_of SiteHtml::BDM_TABLE
    end
    it 'retourne une table qui existe' do
      expect(app.table_tickets).to be_exist
    end
  end

  describe 'create_ticket' do
    it 'répond' do
      expect(app).to respond_to :create_ticket
    end
    context 'sans argument' do
      it 'produit une erreur' do
        expect{app.create_ticket}.to raise_error ArgumentError
      end
    end
    context 'avec deux arguments définis' do
      it 'crée le ticket spécifié' do
        tid   = "tickettestcreateticket"
        tcode = "debug 'ca'"
        res = app.create_ticket(tid, tcode)
        expect(res).to be_instance_of App::Ticket
        expect(app.table_tickets.count(where:{id: tid})).to eq 1
      end
    end
    context 'avec un code et un ID à nil' do
      it 'ne produit pas d’erreur' do
        expect{app.create_ticket(nil, "debug 'ca'")}.not_to raise_error
      end
      it 'définit un ID de 32 charactères pour le ticket' do
        tk = app.create_ticket(nil, "debug 'ca'")
        expect(tk).to be_instance_of App::Ticket
        expect(tk.id).not_to eq nil
        expect(tk.id).to be_instance_of String
        expect(tk.id.length).to eq 32
      end
    end
  end

  describe 'ticket' do
    it 'répond' do
      expect(app).to respond_to :ticket
    end
    context 'sans ticket défini' do
      it 'retourne nil' do
        app.instance_variable_set('@ticket', nil)
        expect(app.ticket).to eq nil
      end
    end
    context 'avec un ticket défini' do
      before(:all) do
        @start_time   = Time.now.to_i - 5
        @ticket_id    = "unidpourvoir"
        @ticket_code  = "debug 'C’est le code à jouer'"
      end
      it 'retourne l’instance App::Ticket du ticket' do
        app.create_ticket @ticket_id, @ticket_code
        expect(app.ticket).to be_instance_of App::Ticket
      end

      it 'répond à #id' do
        expect(app.ticket).to respond_to :id
      end
      it '#id retourne la bonne valeur' do
        expect(app.ticket.id).to eq @ticket_id
      end
      it 'répond à #code' do
        expect(app.ticket).to respond_to :code
      end
      it '#code retourne le code à exécuter' do
        expect(app.ticket.code).to eq @ticket_code
      end
      it 'répond à #user_id' do
        expect(app.ticket).to respond_to :user_id
      end
      it '#user_id retourne l’ID de l’user' do
        expect(app.ticket.user_id).to eq user.id
      end
      it 'répond à #created_at' do
        expect(app.ticket).to respond_to :created_at
      end
      it '#created_at retourne une bonne valeur' do
        expect(app.ticket.created_at).to be > @start_time
      end
      it 'répond à #updated_at' do
        expect(app.ticket).to respond_to :updated_at
      end
      it '#updated_at retourne une bonne valeur' do
        expect(app.ticket.updated_at).to be > @start_time
      end
      it 'répond à #link' do
        expect(app.ticket).to respond_to :link
      end
      it '#link retourne le lien vers le ticket' do
        res = app.ticket.link "Pour voir"
        expect(res).to eq "<a href=\"#{site.distant_host}?tckid=#{app.ticket.id}\">Pour voir</a>"
      end
      it 'répond à #exec' do
        expect(app.ticket).to respond_to :exec
        # Sera testé plus bas
      end
      it 'répond à #delete' do
        expect(app.ticket).to respond_to :delete
      end
      it '#delete détruit le ticket' do
        ticket = app.create_ticket("pourtesterdelete", "1 + 4")
        expect(ticket).to be_exist
        ticket.delete
        expect(ticket).not_to be_exist
      end
    end
  end


  describe 'save_ticket' do
    it 'répond' do
      expect(app).to respond_to :save_ticket
    end
    context 'sans ticket' do
      it 'produit une erreur' do
        app.instance_variable_set('@ticket', nil)
        expect{app.save_ticket}.to raise_error
      end
    end
    context 'avec un ticket pas encore enregistré' do
      before(:all) do
        @ticket = App::Ticket::new("pourvoirleticket", "debug 'un code'")
        app.instance_variable_set('@ticket', @ticket)
      end
      it 'l’enregistre' do
        expect(app.table_tickets.count(where:"id = '#{app.ticket.id}'")).to eq 0
        expect{app.save_ticket}.not_to raise_error
        expect(app.table_tickets.count(where:"id = '#{app.ticket.id}'")).to eq 1
      end
    end
  end

  describe 'get_ticket' do
    it 'répond' do
      expect(app).to respond_to :get_ticket
    end
  end

  describe 'ticket.exec' do
    it 'répond' do
      expect(app).to respond_to :execute_ticket
    end
    context 'avec un code valide' do
      it 'exécute le code du ticket' do
        now = Time.now.to_i
        ticket = app.create_ticket("pouravoirexec", "$variable = #{now}")
        expect(ticket).to be_exist
        expect($variable).to eq nil
        ticket.exec
        expect($variable).to eq now
      end
      it 'détruit le ticket' do
        now = Time.now.to_i + 5
        ticket = app.create_ticket("pouravoirexec", "$variable = #{now}")
        expect(ticket).to be_exist
        ticket.exec
        expect(ticket).not_to be_exist
      end
    end

    context 'avec un code invalide' do
      it 'produit une erreur fatale' do
        now = Time.now.to_i + 10
        ticket = app.create_ticket("pourvoirexec", "choupinette #{now}")
        expect{ticket.exec}.to raise_error
      end
      it 'ne détruit pas le ticket' do
        now = Time.now.to_i + 15
        ticket = app.create_ticket("autrepourvoirexec", "choupinette #{now}")
        expect(ticket).to be_exist
        expect{ticket.exec}.to raise_error
        expect(ticket).to be_exist
      end
    end
  end

  describe 'execute_ticket' do
    it 'répond' do
      expect(app).to respond_to :execute_ticket
    end
    context 'sans argument' do
      it 'produit une erreur' do
        app.instance_variable_set('@ticket', nil)
        expect{app.execute_ticket}.to raise_error ArgumentError
      end
    end
    context 'avec en argument un ticket qui n’existe pas ou plus' do
      it 'produit une erreur non fatale (juste une message)' do
        res = app.execute_ticket "unmauvais#{NOW}ticketpourvoir"
        expect(res).to eq false
      end
    end
    context 'avec en argument un ticket qui existe' do
      it 'exécute le code du-dit ticket' do
        $variable = nil
        @tid = "mon#{NOW}ticket#{NOW}"
        app.create_ticket(@tid, "$variable = '#{@tid}'")
        expect($variable).to eq nil
        res = app.execute_ticket @tid
        expect(res).to eq true
        expect($variable).to eq @tid
      end
    end
  end

  describe 'delete_ticket' do
    it 'répond' do
      expect(app).to respond_to :delete_ticket
    end
    it 'détruit le ticket' do
      ticket = app.create_ticket "pourtestdeleteticket", "1+3"
      expect(ticket).to be_exist
      app.delete_ticket
      expect(ticket).not_to be_exist
    end
  end

  # check_ticket
  describe 'check_ticket' do
    it 'répond' do
      expect(app).to respond_to :check_ticket
    end
    context 'sans ticket défini dans les paramètres' do
      it 'ne fait rien' do
        param(:tckid => nil)
        res = app.check_ticket
        expect(res).to eq nil
      end
    end
    context 'avec un ticket défini dans les paramètres mais inexistant' do
      it 'retourn false (et affiche un message d’erreur)' do
        param(:tckid => "unticketinexistantfakes")
        expect(app.check_ticket).to eq false
      end
    end
    context 'avec un ticket défini et existant' do
      it 'joue le ticket et retourne true' do
        tid = "monticketpourcheckticket"
        code = "$variable = 'variable après check_ticket'"
        app.create_ticket(tid, code)
        param(:tckid => tid)
        $variable = nil
        expect($variable).to eq nil
        res = app.check_ticket
        expect(res).to eq true
        expect($variable).to eq "variable après check_ticket"
      end
    end
  end

end
