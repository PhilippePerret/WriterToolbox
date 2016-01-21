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

  # Relève toutes les données de l'instance pour éviter les
  # requêtes à répétition et les dispatche dans les variables
  # Retourne toujours les données, sous forme de Hahs
  def get_all
    @data = nil # pour forcer la relève
    dispatch data
    return data
  end

  # Dispatche les données +hdata+ dans les variables d'instance
  def dispatch hdata
    hdata.each { |k, v| instance_variable_set( "@#{k}", v ) }
  end

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

    # Le Hash qui sera retourné, ou pour contenir la
    # données unique à retourner
    retour = Hash::new

    # On essaie d'abord de les obtenir dans les données qui
    # ont peut-être été relevées par un get_all
    @data ||= Hash::new
    rest_keys = Array::new
    keys.each do |key|
      if @data.has_key?( key )
        retour.merge!( key => @data[key] )
      else
        rest_keys << key
      end
    end

    # On doit relever dans la table les clés manquantes
    unless rest_keys.empty?
      retour_table = table.select( colonnes: keys, where: { id: id } ).values.first
      retour.merge!(retour_table) unless retour_table.nil?
    end

    # Le retour suivant les cas
    if retour.nil?
      return nil
    elsif want_unique_data
      return retour[keys.first]
    else
      return retour
    end
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
    # On actualise les variables d'instance et les données
    # déjà consignées dans @data
    @data ||= Hash::new
    hdata.each do |k, v|
      instance_variable_set("@#{k}", v)
      @data[k] = v
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
