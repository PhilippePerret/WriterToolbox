# encoding: UTF-8
=begin

  Méthodes utiles pour la base de données, la table des
  connexions provisoires.

=end
class Connexions
class Connexion
class << self

  # Exécuter une requête dans la table et retourner le
  # résultat
  def request req
    site.dbm_base_execute(req)
  end

  # Sélection dans la table des connexions
  def select request = nil
    table.select(request)
  end

  # Table contenant les données de connexions
  def table
    @table ||= site.dbm_table(:hot, 'connexions_per_ip')
  end

end #/<< self
end #/Connexion
end #/Connexions
