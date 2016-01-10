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

  # Relève toutes les données dans la table
  # Retourne {Hash} des données ou NIL si la donnée n'existe pas
  def data
    @data ||= begin
      id.nil? ? Hash::new : table.select(where: {id: id}).values.first
    end
  end

  def select params
    table.select(params)
  end

  # +key+ Symbol (la propriété) ou liste de Symbol
  # Retourne un Hash (si liste de Symbol) ou la valeur (si Symbol)
  def get keys
    want_unique_data = false == keys.instance_of?(Array)
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
    # On actualise les variables d'instance
    hdata.each { |k, v| instance_variable_set("@#{k}", v) }
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
