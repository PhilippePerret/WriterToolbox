# encoding: UTF-8
class Unan
class Program

  # {Any} Retourne le jour programme courant au format +as+
  #   :human      Sous la forme "2e jours"
  #   :nombre     Sous la forme `2`
  #   :instance   Instance Unan::Program::PDay
  #
  # NOTE : Si c'est l'instance qui est demandée et que le
  # jour-programme courant n'est pas défini (premier), la méthode
  # retourne NIL. Dans les autres formats, elle retourne 1 ou
  # "1er jour".
  # NOTE : C'est une `variable` de l'auteur de name :current_pday
  def current_pday as = :nombre # ou :human
    @current_pday ||= auteur.get_var(:current_pday, :none)
    # En fonction du type du retour
    case as
    when :instance
      @current_pday == :none ? nil : PDay::new(self, @current_pday)
    when :human, :humain
      @current_pday = 1 if @current_pday == :none
      mark = @current_pday == 1 ? "er" : "e"
      "#{@current_pday}<sup>#{mark}</sup> jour"
    when :nombre, :number
      @current_pday == :none ? 0 : @current_pday
    else
      @current_pday
    end
  end
  def current_pday= valeur ; @current_pday = valeur end

end #/Program
end #/Unan
