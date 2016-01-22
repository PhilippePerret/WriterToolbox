# encoding: UTF-8
=begin

Instance d'un gel en particulier

=end
class SiteHtml
class Gel

  # Nom du gel, i.e. nom du dossier contenant ses éléments
  attr_reader :name

  def initialize gel_name
    @name = gel_name
  end

  # ---------------------------------------------------------------------
  # Les deux méthodes de gel principales
  #
  def gel options = nil

  end
  def degel options = nil

  end
  #
  # ---------------------------------------------------------------------
  def exist?
    folder.exist?
  end

  # {SuperFile} Dossier contenant les éléments du gel
  def folder
    @folder ||= self.class::folder_data + gel_name
  end

end #/Gel
end #/SiteHtml
