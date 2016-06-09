# encoding: UTF-8
raise_unless_admin
=begin

  Module d'édition ou de création d'une citation.

=end
class Citation
class << self
  def save
    check_data || return
    debug "cdata : #{cdata.inspect}"
    if cdata[:id].nil?
      # C'est une nouvelle citation
      id_new_citation = table.insert( cdata )
      param(citation: cdata.merge(id: id_new_citation))
      flash "Création de la nouvelle citation opérée (##{id_new_citation})."
    else
      table.update(cdata[:id], cdata)
      flash "Modification de la citation ##{cdata[:id]} enregistrée."
    end
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