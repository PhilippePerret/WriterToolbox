# encoding: UTF-8
class Cnarration
class << self
  def folder_data
    @folder_data ||= site.folder_data + "unan/pages_cours/cnarration"
  end
  def folder_data_semidyn
    @folder_data_semidyn ||= site.folder_data + "unan/pages_semidyn/cnarration"
  end
end #/<< self
end #/Cnarration
