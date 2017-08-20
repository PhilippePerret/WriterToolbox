

# Retourne LE ticket correspondant aux données hdata
def db_get_ticket_with hdata
  db_get_tickets_with(hdata).first
end
# Retourne LES tickets correspondant aux données +hdata+
def db_get_tickets_with hdata
  whereclause   = []
  prepared_data = []
  hdata.each do |k, v|
    whereclause << "#{k} = ?"
    prepared_data << v
  end
  whereclause = "WHERE #{whereclause.join(' AND ')}"
  request = "SELECT * FROM tickets #{whereclause}"
  db_client.query('use `boite-a-outils_hot`')
  statement = db_client.prepare(request)
  statement.execute(*prepared_data).collect{|row| row}
end
