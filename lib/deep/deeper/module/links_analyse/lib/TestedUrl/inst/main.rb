# encoding: UTF-8
class TestedPage
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # IDentifiant de l'instance dans la classe
  #
  # Pour la récupérer :
  #     instance = TestedPage[<id>]
  #
  attr_accessor :id

  attr_reader :route

  # Liste Array des erreurs éventuellement rencontrées
  attr_reader :errors

  # Instanciation d'une url
  def initialize route
    @route = route.strip
    self.class << self
    @errors = Array.new
  end

  def url
    @url ||= begin
      case route
      when  /^https?\:\/\// then route
      else File.join(self.class.base_url, route)
      end
    end
  end



end
