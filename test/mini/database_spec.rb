# encoding: UTF-8
=begin

Tests minimum des bases de données

Pour le moment, sert à implémenter les tests des bases

=end

require './data/secret/data_phil'

test_base "users.users" do
  description "Test des données de l'administrateur principal"

  # La rangée #1 doit exister
  row(id: 1).exists?

  # On prend les données de la première rangée
  hdata = row(1).data
  # On les teste (avec les case-méthode de THash)
  hdata.has(id: 1)
  hdata.has(pseudo: "Phil")
  hdata.has(mail: DATA_PHIL[:mail], password: DATA_PHIL[:password])

end
