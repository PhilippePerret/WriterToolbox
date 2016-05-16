# encoding: UTF-8
=begin

Tests minimum des bases de données

Pour le moment, sert à implémenter les tests des bases

=end


test_base "users.users" do
  description "Test des données de l'administrateur principal"

  require './data/secret/data_phil'

  # La rangée #1 doit exister
  row(id: 1).exists
  hdata = row(1).data
  hdata.has(id: 1, pseudo: "Phil", options: /^7/)
  hdata.has_not(password: DATA_PHIL[:password])

end

test_base "users.users" do
  description "Test des données de Marion"

  # Ma petite rangée #3 doit exister et comporter les bonnes
  # données
  require './data/secret/data_marion'
  marion = row(id: 3)
  marion.exists
  hdata = marion.data
  hdata.has(id: 3, pseudo: "Marion", mail: DATA_MARION[:mail], options: /^4/)
  hdata.has_not(password: DATA_MARION[:password])

end
