# encoding: UTF-8
class Array

  ##
  #
  # Reçoit une liste de paths absolue et retourne la même
  # liste avec des paths relatives par rapport à l'application
  #
  # NOTE
  #
  #   * La méthode `as_relative_path' doit être implémenté
  #     pour l'extension String
  #
  def as_relative_paths
    self.collect { |p| p.as_relative_path }
  end
  alias :as_relative_path :as_relative_paths

  # Prend la liste {Array}, sépare toutes les valeurs par des virgules sauf
  # les deux dernières séparées par un "et"
  def pretty_join
    all   = self.dup
    return "" if all.count == 0
    return all.first.to_s if all.count == 1
    last  = all.pop.to_s
    all.join(', ') + " et " + last
  end

  def nil_if_empty
    self.empty? ? nil : self
  end
  
end
