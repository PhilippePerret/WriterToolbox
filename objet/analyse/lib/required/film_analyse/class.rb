# encoding: UTF-8
class FilmAnalyse

  extend MethodesMainObjet

  class << self

    def titre; @titre ||= "Les Analyses de films".freeze end

  end # << self
end #/FilmAnalyse
