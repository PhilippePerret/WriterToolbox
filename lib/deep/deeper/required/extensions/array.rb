# encoding: UTF-8
class ::Array

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

  # Retourne la note sur vingt de [note, note maximale] en gardant
  # +decimales+ nombre après la virgules.
  # Par exemple :
  #   [15, 20].sur_vingt    # => 15.0
  #   [150, 200].sur_vingt  # => 15.0
  #   [10.to_f/3, 20].sur_vingt(3)  # => 3.333
  def sur_vingt decimales = 2
    (self.first.to_f * 20 / self.last.to_f).round(decimales)
  end


end
