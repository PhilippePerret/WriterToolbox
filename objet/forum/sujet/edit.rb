# encoding: UTF-8

# On crée toujours le sujet avant de passer par ici donc
# on peut le prendre en REST
def sujet
  @sujet ||= site.objet
end


class Forum
class Sujet

  def save
    check_and_dispatch_data_param || return
    set( @data4save )
    flash "#{human_type} ##{id} enregistré#{human_e}."
  end

  def human_type
    TYPES[type_s][:htype]
  end
  def human_e
    TYPES[type_s][:feminine] ? "e" : ""
  end

  # Méthode qui prend les données en paramètre et
  def check_and_dispatch_data_param
    dp = data_param
    dp[:id]   = dp[:id].to_i_inn
    raise "L'ID a changé, ça n'est pas normal du tout…" if dp[:id] != id
    dp.delete(:id)
    dp[:name] = dp[:name].nil_if_empty
    raise "Le sujet ou la question doit être définie" if dp[:name].nil?
    dp[:categorie] = nil if dp[:categorie].empty?
    raise "La catégorie devrait être définie…" if dp[:categorie].nil?
    dp[:type_s] = dp[:type_s].to_i_inn
    raise "Le type_s devrait être défini…" if dp[:type_s].nil?
    raise "Le type_s ne possède pas une bonne valeur…" if dp[:type_s] < 0 || dp[:type_s] > 9

    # On dispatch les valeurs
    dp.each { |k, v| instance_variable_set("@#{k}", v) }

    bit_validation = user.grade > 6 ? 1 : 0

    dp.delete(:type_s)
    @data4save = dp.merge( options: "#{bit_validation}#{type_s}" )

  rescue Exception => e
    error e.message
  else
    true
  end

  def data_param ; @data_param ||= param(:sujet) end

end #/Sujet
end #/Forum


case param(:operation)
when 'save_sujet'
  sujet.save
end
