class Unan
class Bureau

  # Retourne une liste d'instances des pages de
  # cours à lire
  def pages_cours
    @pages_cours ||= begin
      ids = get_var(:pages_cours).nil_if_empty.nil?
      unless ids.nil?
        ids.collect{|pid| Unan::Program::PageCours::get(pid)}
      else
        Array::new
      end
    end
  end

end #/Bureau

class Program
class PageCours

  # Affichage complet de la page de cours pour le bureau
  def output_bureau

  end

end #/PageCours
end #/Program
end #/Unan
