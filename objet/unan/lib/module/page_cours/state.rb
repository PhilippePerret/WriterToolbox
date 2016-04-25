# encoding: UTF-8
class Unan
class Program
class PageCours

  # Return TRUE si la page-cours concerne une page
  # ou un titre Narration
  def narration?
    @is_narration = (narration_id != nil) if @is_narration.nil?
    @is_narration
  end

end #/PageCours
end #/Program
end #/Unan
