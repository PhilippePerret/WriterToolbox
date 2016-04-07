# encoding: UTF-8
class FilmAnalyse

  extend MethodesMainObjets

  class << self

    def titre; @titre ||= "Analyses de films".freeze end

  end # << self
end #/FilmAnalyse
