# encoding: UTF-8
class Cnarration
class << self

  # Le superfile contenant l'inventaire des livres narration, avec la
  # présentation de l'état des livres.
  #
  # Ce fichier est produit en demandant `inventory narration` en console.
  #
  def inventory_file
    @inventory_file ||= folder + "cnarration_inventory.html"
  end

  def folder_data
    @folder_data ||= site.folder_data + "unan/pages_cours/cnarration"
  end
  def folder_data_semidyn
    @folder_data_semidyn ||= site.folder_data + "unan/pages_semidyn/cnarration"
  end
end #/<< self
end #/Cnarration
