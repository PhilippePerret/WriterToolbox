# encoding: UTF-8
=begin
Gestion des erreurs de BdD
--------------------------

REQUIS
  * Une méthode générale `error' doit exister, qui reçoit en premier
    argument le message d'erreur.
=end

# La classe d'erreur propre
class BdDError < StandardError; end
class BdD
  ERRORS = {
    # Base de données
    :instance_bad_path => "Le premier argument de BdD::new doit être un String (path de la BdD)",
    # Table
    :bdd_instance_required_for_table  => "Le premier argument de BdD::Table::new doit être une instance BdD.",
    :table_name_required_for_table    => "Le second argument de BdD::Table::new doit être un String (nom de la table)",
    :table_name_invalide => "Le nom de la table est invalide (seulement des minuscules simples et des traits plats).",
    :colonnes_definition_required => "Les colonnes de la table ne sont pas définies. Utiliser la méthode &lt;table>#define pour les définir.",
    :bad_colonne_name => "Nom de colonne invalide dans la table",
    :type_colonne_required => "Type de la colonne requis dans la définition des colonnes de la table.",
    :unknown_type => "Type de données inconnu dans la définition des colonnes de la table.",
    :unknown_constraint => "Contrainte inconnue dans la définition des colonnes de la table.",
    # Méthode #set
    :bad_set_second_arg => "Le second argument transmis à BdD::Table#set devrait être un Hash (clé=>valeur)",
    :bad_set_first_arg => "Le premier argument transmis à BdD::Table#set devrait être un Hash ou un Fixnum (ID de la donnée)",
    :set_bad_id_data => "L'ID de la donnée devrait être un nombre (Fixnum)",
    :set_bad_data_for_data => "Les données transmise à BdD::Table#set pour la donnée devrait être un Hash.",
    :bad_args_with_values_form => "L'argument avec :values doit impérativement définir soit :id soit la condition WHERE dans :where.", 
    :where_clause_hash_required => "La clause WHERE (:where) doit obligatoirement être définie par un Hash, pas par un string, dans cette tournure.",
    # Méthode #delete
    :delete_require_hash_or_id => "La méthode BdD::Table#delete attend en premier argument un Fixnum (ID de la donnée) ou un Hash (définissant :condition ou :where)",
    :delete_invalid_hash => "Le premier argument Hash de la méthode BdD::Table#delete doit définir :condition ou :where."
    
  }
  class << self
  
    ##
    # Produire une erreur
    # +error_mess+
    # {String} Le message d'erreur
    # {Symbol} L'ID du message d'erreur dans ERRORS
    def error error_mess
      error_mess = ERRORS[error_mess] if error_mess.class == Symbol
      error error_mess
    end
  end
end