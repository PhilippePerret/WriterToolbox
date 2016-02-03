# encoding: UTF-8
=begin
Extention de la class App pour la gestion des tickets
=end

class App

  # Méthode appelée par le préambule (./lib/preambule.rb) pour
  # traiter l'éventuel ticket.
  def check_ticket
    return if param(:tckid).nil?
    execute_ticket(param(:tckid))
  end

  # Crée un ticket à partir des données +tid+ et +tcode+
  # +tid+ {String|NIL} ID à donner au ticket, en général un 32 bits
  #       La méthode en calcule un unique si NIL
  # +tcode+ {String} Le code ruby qui devra être exécuté à l'appel
  # du ticket.
  # Retourne le ticket créé, mais ne sert que pour les tests
  # +options+ Permet de passer des données qui ne pourront pas être
  # prises autrement, par exemple l'user_id lorsque c'est une création
  # d'user et qu'il n'y a donc pas de user courant.
  def create_ticket tid, tcode, options = nil
    tid ||= begin
      require 'securerandom'
      SecureRandom.hex
    end
    @ticket = Ticket::new(tid, tcode, options)
    @ticket.create
    @ticket
  end

  # Retourne le lien à coller dans le mail pour activer
  # le ticket +ticket_id+
  def lien_ticket titre_lien
    ticket.link( titre_lien )
  end

  # Exécute le ticket
  # Cette méthode est appelée par le site, au chargement de la
  # page, si une variable tckid est définie.
  # La méthode vérifie que le ticket existe bien
  def execute_ticket tid
    get_ticket(tid)
    if false == ticket.exist?
      error.add "Impossible d'exécuter ce ticket. Il n'existe pas ou plus."
    elsif (user.id != ticket.user_id) && false == user.admin?
      error.add "Vous n'êtes en aucun cas le possesseur de ce ticket, impossible de l'exécuter pour vous."
    else
      ticket.exec
    end
  end

  def save_ticket
    ticket.save
  end

  def get_ticket tid
    @ticket = Ticket::new(tid)
    return nil unless @ticket.exist?
    @ticket
  end

  # Détruit le ticket si l'exécution s'est bien déroulée
  def delete_ticket
    ticket.delete
  end

  def ticket(tid = nil) ; @ticket ||= get_ticket(tid) end

  def table_tickets
    @table_tickets ||= site.db.create_table_if_needed('site_hot', 'tickets')
  end

  # ---------------------------------------------------------------------
  #   La class App::Ticket

  class Ticket

    include MethodesObjetsBdD

    attr_reader :id

    def initialize tid, tcode = nil, options = nil
      @id   = tid
      @code = tcode
      options.each { |k, v| instance_variable_set("@#{k}", v) } unless options.nil?
    end

    # Retourne le lien pour activer le ticket (à copier
    # dans le mail)
    # @usage : Utiliser la méthode app.lien_ticket après avoir
    # utilisé app.create_ticket(id,code)
    def link titre = nil
      titre ||= href
      titre.in_a(href:href)
    end

    # Exécution du ticket (exécute le code enregistré dans la
    # base de données)
    def exec
      eval(code)
    rescue Exception => e
      raise e
    else
      delete
      return true
    end

    def href
      "#{site.distant_host}?tckid=#{id}"
    end

    def save
      if exist?
        table.update(id, data2save)
      else
        create
      end
    end

    def exist?
      table.count(where:{id: id}) > 0
    end

    def create
      table.insert(data4create)
    end

    def data4create
      @data4create ||= {
        id:         id,
        code:       code,
        user_id:    @user_id || user.id,
        created_at: NOW,
        updated_at: NOW
      }
    end

    def data2save
      @data2save ||= {
        code:         code,
        user_id:      user_id,
        updated_at:   NOW
      }
    end

    def user_id   ; @user_id  ||= get(:user_id) end
    def code      ; @code     ||= get(:code)    end

    def table
      @table ||= app.table_tickets
    end
  end
end
