# encoding: UTF-8
class SiteHtml
class TestSuite
class TestBase

  # {String} Affixe de la base
  attr_reader :affixe

  def initialize affixe
    @affixe = affixe
  end

  # ---------------------------------------------------------------------
  #   Méthodes propriétés
  # ---------------------------------------------------------------------
  def name  ; @name ||= "#{affixe}.db"        end
  def path  ; @path ||= site.folder_db + name end

  # ---------------------------------------------------------------------
  #   Méthodes d'état
  # ---------------------------------------------------------------------
  def exist?
    path.exist?
  end


end #/TestBase
end #/TestSuite
end #/SiteHtml
