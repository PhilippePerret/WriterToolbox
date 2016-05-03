# encoding: UTF-8
class Unan
class Program

  # Retourne "1er jour" ou "Xe jour"
  def current_pday_humain
    @current_pday_humain ||= begin
      er = current_pday > 1 ? "e" : "er"
      "#{current_pday}<sup>#{er}</sup> jour"
    end
  end

end #/Program
end #/Unan
