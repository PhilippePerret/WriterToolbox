# encoding: UTF-8
raise_unless_admin
=begin

  Module d'édition ou de création d'une citation.

=end
class Citation
class << self
  def save
    check_data || return

    if cdata[:id].nil?
      # C'est une nouvelle citation
      cdata.delete(:id)
      cdata.merge! created_at: NOW
      id_new_citation = table_citations.insert( cdata )
      cdata.merge!(id: id_new_citation)
      param(citation: cdata.merge(id: id_new_citation))
      flash "Création de la nouvelle citation opérée (##{id_new_citation}).#{ajout_message_descriptions}"
    else
      table_citations.update(cdata[:id], cdata)
      flash "Modification de la citation ##{cdata[:id]} enregistrée.#{ajout_message_descriptions}"
    end

    # On ajoute aux données la short_url (bitly)
    # en la calculant si nécessaire
    if cdata[:bitly].nil?
      icit = Citation.new(cdata[:id])
      icit.set(bitly: icit.short_url)
      flash "Bitly calculée : #{icit.short_url}"
    end

  end

  # Un message ajouté à la confirmation de l'enregistrement pour
  # indiquer le nombre de citations qui ont une description et celles
  # qui ne l'ont pas.
  def ajout_message_descriptions
    sans_desc     = table_citations.count(where: 'description IS NULL OR description = ""')
    nombre_total  = table_citations.count
    avec_desc     = nombre_total - sans_desc
    "Nombre total de citations : #{nombre_total} - avec description : #{avec_desc} - reste à expliciter : #{sans_desc}".in_div(class: 'small')
  end

  def descrition_nil?
    @description_was_nil
  end

  def check_data
    cdata[:description] = cdata[:description].gsub(/[\r\n]/,'').gsub(/[\r\n]/,'').nil_if_empty
    cdata[:citation] = cdata[:citation].nil_if_empty
    cdata[:citation] != nil || raise('Il faut donner la citation.')
    cdata[:auteur] = cdata[:auteur].nil_if_empty
    cdata[:auteur] != nil || raise('Il faut donner l’auteur de la citation.')
    cdata[:source] = cdata[:source].nil_if_empty
    cdata[:id] = cdata[:id].nil_if_empty
    cdata[:id].nil? || cdata[:id] = cdata[:id].to_i
    cdata[:bitly] = cdata[:bitly].nil_if_empty
    @description_was_nil =
      if cdata[:id].nil?
        true
      else
        new(cdata[:id]).description == nil
      end
  rescue Exception => e
    error e.message
  else
    true
  end

  def cdata
    @data ||= param(:citation)
  end
end #/ << self
end #/ Citation


case param(:operation)
when 'save_citation'
  Citation.save
end
