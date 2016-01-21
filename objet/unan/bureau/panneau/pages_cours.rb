class Unan
class Bureau

  # Retourne une liste d'instances des pages de
  # cours à lire
  def pages_cours
    @pages_cours ||= begin
      user.get_var(:pages_ids, Array::new).uniq.collect { |pid| Unan::Program::PageCours::get(pid) }
    end
  end
  def last_pages_cours
    user.program.works(completed:true, type: :pages).collect do |hwork|
      Unan::Program::PageCours::get(hwork[:item_id])
    end
  end

  # Cf. l'explication dans home.rb
  def missing_data
    @missing_data ||= begin
      # TODO Indiquer avec cette méthode quand des pages auraient dû être lues,
      # ou marquées lues et que la date a été dépassée.
      nil # pour le moment
    end
  end

end #/Bureau

class Program
class PageCours

  # Affichage complet de la page de cours pour le bureau
  def output_bureau
    "[sortie de la page ##{id} pour le bureau]"
  end

end #/PageCours
end #/Program
end #/Unan
