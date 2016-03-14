# encoding: UTF-8
class Cnarration
class Livre

  # Dossier dans ./data/unan/page_cours/cnarration
  def folder
    @folder ||= Cnarration::folder_data + "#{data[:folder]}"
  end
  def folder_semidyn
    @folder_semidyn ||= Cnarration::folder_data_semidyn + "#{data[:folder]}"
  end

end #/Livre
end #/Cnarration
