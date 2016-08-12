# encoding: UTF-8
class FilmAnalyse
  class << self

    def lien_participer titre = nil, options = nil
      titre ||= "participer aux analyses"
      options ||= Hash.new
      options.merge!(href:'analyse/participer')
      titre.in_a(options)
    end

  end # << self
end # FilmAnalyse
