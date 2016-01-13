# encoding: UTF-8
class Unan
class Program

  # Retourne le jour programme courant au format +as+
  #
  def current_pday as = :nombre # ou :human
    @ijour_actif ||= begin
      ijr = nil
      (1..365).each do |ijour|
        if day_overview(ijour).actif?
          ijr = ijour.freeze
          break
        end
      end
      ijr.nil? ? 1 : ijr
    end

    # Type du retour
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
