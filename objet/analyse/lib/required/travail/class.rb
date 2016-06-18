# encoding: UTF-8
class FilmAnalyse
class << self

  # -> MYSQL ANALYSE
  def table_travaux
    @table_travaux ||= site.db.create_table_if_needed('analyse', 'travaux')
  end
end # << self
end #/FilmAnalyse
