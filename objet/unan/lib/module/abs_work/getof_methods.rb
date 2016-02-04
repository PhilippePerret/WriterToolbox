# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end

module MethodesLinksProgramThings

  def all_liens_pdays owner, arr_pdays_ids
    arr_pdays_ids = [arr_pdays_ids] unless arr_pdays_ids.instance_of?(Array)
    UnanAdmin::require_module 'abs_pday'

    s = arr_pdays_ids.count > 1 ? "s" : ""
    sub_log "Le #{owner.type} ##{owner.id} (#{owner.titre}) appartient au P-Day#{s} : #{arr_pdays_ids.pretty_join}"
    arr_pdays_ids.collect do |pdid|
      ipday = Unan::Program::AbsPDay::get(pdid)
      e = pdid > 1 ? "e" : "er"
      (
        "#{pdid}<sup>#{e}</sup> Jour-Programme : " +
        ipday.lien_edit("[Edit]") +
        ipday.lien_show("[Show]") +
        ipday.lien_delete("[Détruire]", {class:'warning'})
      ).in_div
    end.join("")
  end

  def all_liens_pages_cours arr_ids
    arr_ids = [arr_ids] unless arr_ids.instance_of?(Array)
  end

end

class Unan
class Program
class AbsWork

  include MethodesLinksProgramThings

  def log mess
    console.log mess
  end
  def sub_log mess
    # SiteHtml::Admin::Console::sub_log mess
    console.sub_log mess
  end

  # Retourne le PDay absolu du travail courant
  # Note : Un seul pour un AbsWork
  def getof_pday
    error_does_not_exist unless exist?
    res = Unan::table_absolute_pdays.select(where:"works LIKE '%#{id}%'", colonnes:[:works]).values
    # Ci-dessus on peut avoir récupérer aussi bien "121 12 212" pour "12", mais
    # il ne faudrait garder que "12" par exemple. On filtre ci-dessous
    id_str = id.to_s.freeze
    ids = res.select do |hdata|
      hdata[:works].split(' ').include?(id_str)
    end.collect{|h| h[:id]}

    raise "Le work ##{id} n'est associé à aucun jour-programme." if ids.count == 0
    sub_log all_liens_pdays( self, ids ) # Module MethodesLinksProgramThings
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  end

  # Retourne le Quiz associé à cet AbsWork, s'il existe
  def getof_quiz
    error_does_not_exist unless exist?

  end

  # Retourne tous les exemples de cet AbsWork, s'il y en a
  def getof_exemple
    error_does_not_exist unless exist?

  end

  # Retourne la page de cours associée à cet AbsWork, s'il
  # est associé à une page de cours
  def getof_page_cours
    error_does_not_exist unless exist?
    if type_w.nil?
      raise "Le type_w de AbsWork##{id} n'est pas défini… Impossible de savoir si une page de cours lui est associée."
    elsif data_type_w[:id_list] == :pages
      sub_log "Page de cours ##{item_id.inspect} pour le work ##{id} : #{titre}."
      ipage = Unan::Program::PageCours::get(item_id)
      UnanAdmin::require_module 'page_cours'
      sub_log "<br />#{ipage.lien_edit("[edit]")} #{ipage.lien_show("[show]")} #{ipage.lien_delete("[détruire]")}"
    else
      sub_log "Pas de page de cours."
      false
    end
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  end

  def error_does_not_exist
    raise "Le work absolute ##{id} n'existe pas, impossible d'obtenir ce que vous voulez."
  end


end #/AbsWork
end #/Program
end #/Unan
