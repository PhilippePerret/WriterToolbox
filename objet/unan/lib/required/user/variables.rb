# encoding: UTF-8
class User

  # Toutes les variables (valeurs de la table `variables` qui
  # fonctionne en name: <valeur>)
  def variables
    @variables ||= begin
      h = Hash::new
      table_variables.select.values.each do |d|
        h.merge! d[:name].to_sym => var_value_by_type(d)
      end
      # debug "variables : #{h.inspect}"
      h
    end
  end

  VARIABLES_TYPES = [String, Fixnum, Bignum, Float, Hash, Array, NilClass]
  # Mets la variable +var_name+ à +var_value+ dans la table `variables`
  # de l'user.
  def set_var var_name, var_value = nil

    case var_name
    when Hash then var_name
    else { var_name => var_value }
    end.each do |var_name, var_value|

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

      table_variables.set(where:{name: var_name}, values:{name: var_name, value: saved_value, type: type})

    end # /loop sur toutes les variables à définir
  end

  # Récupérer la valeur de la variable `var_name` (qui peut avoir
  # n'importe quel type)
  def get_var var_name
    h = table_variables.get(where:{name: var_name})
    return nil if h.nil?
    var_value_by_type h
  end

  # Prend la donnée définie par +h+ (contenant une valeur
  # string et un type par nombre) et retourne la valeur dans
  # son bon type, par exemple un nombre, ou un Hash, etc.
  # Sert à la table `variables` qui enregistre n'importe quel
  # type de donnée scalaire et la restitue telle quelle.
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

end
