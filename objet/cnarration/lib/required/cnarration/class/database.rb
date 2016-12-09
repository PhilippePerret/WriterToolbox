# encoding: UTF-8
class Cnarration
class << self

  # Array des pages (seulement des pages) où chaque élément est
  # un hash de toutes les données de la page.
  def pages
    @pages ||= Cnarration.table_pages.select(where: "options LIKE '1%'")
  end

  def chapitres
    @chapitres ||= Cnarration.table_pages.select(where: "options LIKE '3%'")
  end

  def sous_chapitres
    @sous_chapitres ||= Cnarration.table_pages.select(where:"options LIKE '2%'")
  end

  def textes_types
    @textes_types ||=  Cnarration.table_pages.select(where:"options LIKE '5%'")
  end


  def table_evaluation
    @table_evaluation ||= site.dbm_table(:cnarration, 'comments')
  end
  def table_pages
    @table_pages ||= site.dbm_table(:cnarration, 'narration')
  end
  def table_tdms
    @table_tdms ||= site.dbm_table(:cnarration, 'tdms')
  end
end #/<<self
end #/Cnarration
