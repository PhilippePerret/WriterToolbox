class Unan
class Bureau

  # Retourne une liste d'instances des pages de
  # cours à lire
  def pages_cours
    @pages_cours ||= begin
      # Attention, pour bien comprendre, il faut comprendre que
      # l'identifiant dans :pages_ids est celui du travail (work)
      # mais que c'est la propriété `item_id` du travail absolu
      # de ce travail qui définit l'id de la page de cours à lire.
      good_list = Array::new() # pour correction
      curr_list = user.get_var(:pages_ids, Array::new)
      pages = curr_list.uniq.compact.collect do |wid|
        work = user.program.work(wid)
        next if work.abs_work.id == nil       # problème
        next if work.abs_work.item_id == nil  # problème
        good_list << wid
        Unan::Program::PageCours::get(work.abs_work.item_id)
      end
      # Corriger les problèmes si on en trouve
      if good_list != curr_list
        debug "La liste des :pages_ids a dû être corrigée (originale : #{curr_list.inspect} / corrigée : #{good_list.inspect})"
        user.set_var(pages_ids: good_list)
      end
      pages
    end
  end
  def last_pages_cours
    user.program.works(completed:true, type: :pages, count:5).collect do |hwork|
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
    (
      infos_if_admin  +
      titre_page      +
      boutons_page
    ).in_div(class:'work page')
  end

  def infos_if_admin
    return "" unless user.admin?
    "Page ##{id}".in_div(class:'right tiny')
    # TODO: Plus tard, un lien pour éditer les données et le texte
  end

  def titre_page
    titre.in_div(class:'titre')
  end

  def boutons_page
    (
      "Marquer la page lue".in_a(href:"")
    ).in_div(class:'buttons')
  end

end #/PageCours
end #/Program
end #/Unan
