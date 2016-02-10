# encoding: UTF-8
class FilmAnalyse
  class << self

    def lien_participer titre = nil
      titre ||= "participer aux analyses"
      titre.in_a(href:'analyse/participer')
    end

  end # << self
end # FilmAnalyse
