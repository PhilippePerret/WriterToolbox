# encoding: UTF-8
raise_unless_admin

UnanAdmin::require_module 'exemple'

class Unan
class Program
class Exemple

  # Enregistrement de l'exemple dans la table, le crée ou
  # l'actualise
  # Retourne TRUE si tout s'est bien passé, FALSE dans le
  # cas contraire.
  def save
    check_data_or_raise || (return false)
    id.nil? ? create : table.update(id, data2save)
    return true
  end

  def create
    @id = table.insert(data4create)
  end

  def data2save
    @data2save ||= begin
      common_data
    end
  end
  def data4create
    @data4create ||= begin
      common_data.merge!(created_at:NOW)
    end
  end
  def common_data
    @common_data ||= {
      titre:        param_data(:titre)    || titre,
      content:      param_data(:content)  || content,
      source_type:  assemble_source_type  || source_type,
      updated_at:   NOW
    }
  end
  def param_data
    @param_data ||= param(:exemple)
  end
  def assemble_source_type
    "#{param_data[:source_src]}" +
    "#{param_data[:source_year]}" +
    "#{param_data[:source_pays]}"
  end

  # Vérification des données à enregistrer
  # Note : on les prend des paramètres
  def check_data_or_raise
    dc = param_data.dup
    dc[:titre] = dc[:titre].nil_if_empty
    raise "Il faut fournir le titre de l'exemple !" if dc[:titre].nil?
    raise "Ce titre est trop long (255 caractères max.)" if dc[:titre].length > 255
    dc[:content] = dc[:content].nil_if_empty
    raise "Il faut fournir l'exemple proprement dit !" if dc[:content].nil?
    dc[:source_year] = dc[:source_year].nil_if_empty
    raise "Il faut fournir l'année de l'exemple !" if dc[:source_year].nil?
    raise "L'année doit être composée de 4 chiffres !" if dc[:source_year].gsub(/^[0-9]{4}$/,'') != ""
    raise "L'année ne peut pas être dans le futur, voyons !" if dc[:source_year].to_i > Time.now.year
    dc[:work_id] = dc[:work_id].nil_if_empty
    unless dc[:work_id].nil?
      raise "Le work-id ##{dc[:work_id]} n'existe pas ! (noter qu'il s'agit d'un AbsWork, n'est-ce pas ?)" unless abswork_exist?(dc[:work_id])
    end

    # On remet les données corrigée dans les paramètres avant de
    # renvoyer true
    param(exemple: dc)
  rescue Exception => e
    error e
  else
    true # pour poursuivre
  end

  # Retourne true si le work absolu d'identifiant +wid+ existe,
  # false dans le cas contraire
  def abswork_exist? wid
    Unan::table_absolute_works.count(where:{id: wid.to_i}) > 0
  end

end #/Exemple
end #/Program
end #/Unan

def exemple
  @exemple ||= begin
    if param(:exemple).nil?
    else

    end
  end
end

case param(:operation)
when "save_exemple"
  exemple.save
end
