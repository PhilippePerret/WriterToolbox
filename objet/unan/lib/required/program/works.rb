# encoding: UTF-8
=begin
Extension des instance Unan::Program pour gérer les instances
Work du programme
=end
class Unan
class Program

  # {Unan::Program::Work} Retourne l'instance d'identifiant +wid+
  # du Work du programme courant, ou nil si elle n'existe pas
  def work wid
    wid = wid.nil_if_empty.to_i_inn
    return nil if wid.nil?
    Work::get(self, wid)
  end

  # {Array of Unan::Program::Work} Liste des travaux propres du
  # programme courant en appliquant le filtre +filtre+ s'il est
  # défini.
  # +filtre+
  #   :completed      SI true, les travaux terminés (status 9)
  #                 Si false, seulement les non terminés
  def works filtre = nil
    @works ||= self.table_works.select(order:"created_at ASC").values
    return @works if filtre.nil?

    filtered = @works.dup
    if filtre[:completed]
      filtered.reject! { |h| h[:status] < 9 }
    elsif filtre[:completed] === false
      filtered.reject! { |h| h[:status] == 9 }
    end
    filtered
  end

end #/Program
end #/Unan
