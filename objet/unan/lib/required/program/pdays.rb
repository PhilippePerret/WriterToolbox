# encoding: UTF-8
class Unan
class Program

  # Retourne le jour programme courant au format +as+
  # Note : C'est une variable de name :current_pday
  def current_pday as = :nombre # ou :human
    @ijour_actif ||= user.get_var(:current_pday, 1)
    # En fonction du type du retour
    case as
    when :human, :humain then
      mark = @ijour_actif == 1 ? "er" : "e"
      "#{@ijour_actif}<sup>#{mark}</sup> jour"
    else
      @ijour_actif
    end
  end

end #/Program
end #/Unan
