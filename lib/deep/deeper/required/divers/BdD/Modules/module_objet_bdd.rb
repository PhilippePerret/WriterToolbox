# encoding: UTF-8
=begin
Méthodes pour les objets (instances) des bases de données.

@usage

    Placer `include MethodesObjetsBdD' dans la classe de l'objet
    Noter que ce module est toujours chargé (on utilise les BdD partout)

@requis

    La classe doit définir la méthode-propriété `table' qui retourne
    l'instance BdD::Table de la classe.

=end
module MethodesObjetsBdD

  # Relève toutes les données dans la table atelier.taches ou
  # atelier.past_data
  # Retourne {Hash} des données ou NIL si la donnée n'existe pas
  # Cf. _MANUEL_.md > Module de méthodes d'objet > #data
  def data
    @data ||= begin
      id.nil? ? Hash::new : table.select(where: {id: id}).values.first
    end
  end

  def select params
    table.select(params)
  end

  # Cf. _MANUEL_.md > Module de méthodes d'objet > #get
  def get keys
    want_unique_data = keys.class != Array
    keys = [keys] if want_unique_data
    retour = table.select( colonnes: keys, where: { id: id } ).values.first
    return nil if retour.nil?
    retour = retour[keys.first] if want_unique_data
    retour
  rescue Exception => e
    debug e
    error e
  end

  # Sauve les données dans la donnée
  # +hdata+ {Hash} des données à sauvegarder
  # Alias def set
  def save hdata = nil
    hdata ||= data
    retour = if @id.nil?
      @id = table.insert( hdata )
    else # Update ou Insert
      table.set values: hdata, where: {id: id}
    end
  rescue Exception => e
    error e
  ensure
    return retour
  end
  alias :set :save

  # Détruit la donnée
  # Alias def remove
  def delete
    table.delete(where: { id: id })
  rescue Exception => e
    error e
  end
  alias :remove :delete
end
