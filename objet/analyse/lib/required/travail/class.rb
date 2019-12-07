# encoding: UTF-8
class FilmAnalyse
class << self

  def table_travaux
    @table_travaux ||= site.dbm_table(:boa_biblio, 'travaux_analyses')
  end
end # << self
end #/FilmAnalyse
