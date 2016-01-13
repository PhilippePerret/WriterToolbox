# encoding: UTF-8
require 'json'

class User

  # {Unan::Projet} Le projet courant de l'user, ou nil
  def projet
    @projet ||= Unan::Projet::get_current_projet_of(self.id)
  end
  def projet_id; @projet_id ||= projet.id end

  # Retourne le nombre de +quoi+ de l'user (nombre de
  # messages forum, de pages de cours à lire, etc.)
  def nombre_de quoi
    variables[quoi] || 0
  end

  # Toutes les variables (valeurs de la table `variables` qui
  # fonctionne en name: <valeur>)
  def variables
    @variables ||= begin
      h = Hash::new
      table_variables.select.values.each do |d|
        h.merge! d[:name].to_sym => var_value_by_type(d)
      end
      h
    end
  end

  VARIABLES_TYPES = [String, Fixnum, Bignum, Float, Hash, Array, NilClass]
  # Mets la variable +var_name+ à +var_value+ dans la table `variables`
  # de l'user.
  def set_var var_name, var_value

    # Le type de la variable à sauver
    type = case var_value
    when TrueClass, FalseClass then 7
    else VARIABLES_TYPES.index(var_value.class)
    end

    # La vraie valeur à enregistrer
    saved_value = case var_value
    when TrueClass  then "1"
    when FalseClass then "0"
    when NilClass   then nil
    when Hash, Array  then var_value.to_json
    when Fixnum, Bignum, Float then var_value.to_s
    else var_value.to_s
    end
    table_variables.set({name: var_name, value: saved_value, type: type})
  end

  # Récupérer la valeur de la variable `var_name` (qui peut avoir
  # n'importe quel type)
  def get_var var_name
    h = table_variables.get(where: "name = '#{var_name}'")
    return nil if h.nil?
    var_value_by_type h
  end
  def var_value_by_type h
    # Cf. VARIABLES_TYPES pour connaitre l'ordre
    case h[:type]
    when 0      then h[:value].to_s # String
    when 1, 2   then h[:value].to_i
    when 3      then h[:value].to_f
    when 4, 5   then JSON.parse(h[:value])
    when 6      then nil
    when 7      then h[value] == "1"
    end
  end


  # Return TRUE si l'user vient de s'inscrire au programme
  # un an un script

  # RETURN true si l'user suit le programme Un An Un Script
  # On le sait à partir du moment où il possède un programme
  # ACTIF dans la table des programmes
  def unanunscript?
    program.instance_of?(Unan::Program)
  end

  # Le dossier data de l'user dans ./database/data/unan/user/<id>/
  def folder_data
    @folder_data ||= begin
      d = site.folder_db + "unan/user/#{id}"
      d.build unless d.exist?
      d
    end
  end
end
