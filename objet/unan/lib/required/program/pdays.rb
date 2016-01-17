# encoding: UTF-8
class Unan
class Program

  # {Any} Retourne le jour programme courant au format +as+
  #   :human      Sous la forme "2e jours"
  #   :nombre     Sous la forme `2`
  #   :instance   Instance Unan::Program::PDay
  #
  # NOTE : C'est c'est l'instance qui est demandée et que le
  # jour-programme courant n'est pas défini (premier), la méthode
  # retourne NIL. Dans les autres formats, elle retourne 1 ou
  # "1er jour".
  # NOTE : C'est une `variable` de l'auteur de name :current_pday
  def current_pday as = :nombre # ou :human
    @ijour_actif ||= auteur.get_var(:current_pday, :none)
    # En fonction du type du retour
    case as
    when :instance
      @ijour_actif == :none ? nil : PDay::new(self, @ijour_actif)
    when :human, :humain
      @ijour_actif = 1 if @ijour_actif == :none
      mark = @ijour_actif == 1 ? "er" : "e"
      "#{@ijour_actif}<sup>#{mark}</sup> jour"
    when :nombre, :number
      @ijour_actif == :none ? 1 : @ijour_actif
    else
      @ijour_actif
    end
  end

end #/Program
end #/Unan
