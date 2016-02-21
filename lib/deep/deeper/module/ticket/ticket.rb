# encoding: UTF-8
class App
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
  # @usage : Utiliser la méthode app.ticket.link après avoir
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
    il_existe = table.count(where:{ id: id }, colonnes:[]) > 0
    debug "Le Ticket #{id} existe ? #{il_existe.inspect}"
    unless il_existe
      debug "Il n'existe pas dans la table :"
      debug "#{table.select.pretty_inspect}"
    end
    return il_existe
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

end #/Ticket
end #/App
