# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end

module MethodesLinksProgramThings

  def log mess      ; console.log mess      end
  def sub_log mess  ; console.sub_log mess  end


  def require_all_modules_of chose
    return if instance_variable_get("@module_of_#{chose}_required")
    Unan::require_module chose
    UnanAdmin::require_module chose
    instance_variable_set("@module_of_#{chose}_required", true)
  end


  # Retourne tous les liens édition, aperçu et destruction pour
  # les PDays dont les IDs (ou l'ID) sont fourni en argument
  #
  def all_liens_pdays owner, arr_pdays_ids
    unless @module_absolute_pday_required
      UnanAdmin::require_module 'abs_pday'
      @module_absolute_pday_required = true
    end
    arr_pdays_ids = [arr_pdays_ids] unless arr_pdays_ids.instance_of?(Array)

    s = arr_pdays_ids.count > 1 ? "s" : ""
    sub_log "Le #{owner.type} ##{owner.id} (#{owner.titre}) appartient au P-Day#{s} : #{arr_pdays_ids.pretty_join}"
    arr_pdays_ids.collect do |pdid|
      ipday = Unan::Program::AbsPDay::get(pdid)
      e = pdid > 1 ? "e" : "er"
      (
        "#{pdid}<sup>#{e}</sup> Jour-Programme : " +
        ipday.lien_edit("[Edit]") +
        ipday.lien_show("[Show]") +
        ipday.lien_delete("[Delete]", {class:'warning'})
      ).in_div
    end.join("")
  end

  # Retourne tous les p-days qui répondent à la clause
  # where +where_clause+ en retourne la valeur des colonnes fournies
  # en arguments, ou seulement la valeur {id: id} si aucune colonne
  # n'est fournie.
  def search_pdays_where where_clause, colonnes = []
    Unan::table_absolute_pdays.select(where:where_clause, colonnes:colonnes).values
  end

  def liens_edition_for_allin_ofclass arr_ids, classe, options = nil
    arr_ids = [arr_ids] unless arr_ids.instance_of?(Array)
    arr_ids.collect do |inst_id|
      liens_edition_for( classe::get( inst_id ), options )
    end.join('')
  end

  def liens_edition_for inst, options = nil
    options ||= Hash::new
    (
      inst.lien_edit("[Edit]") +
      inst.lien_show("[Show]", options[:options_show]) +
      inst.lien_delete("[Delete]", {class:'warning'})
    ).in_div
  end

  def all_liens_works arr_ids
    require_all_modules_of 'abs_work'

    liens_edition_for_allin_ofclass(arr_ids, Unan::Program::AbsWork)

  end

  def all_liens_quiz arr_ids
    require_all_modules_of( 'quiz' )
    liens_edition_for_allin_ofclass(arr_ids, Unan::Quiz, {options_show:{user_id:2}})
  end

  def all_liens_exemples arr_ids
    require_all_modules_of('exemple')
    liens_edition_for_allin_ofclass(arr_ids, Unan::Program::Exemple)
  end

  # Retourne tous les liens (édition, aperçu et destruction) pour
  # les pages de cours dont les IDs sont fournis en argument
  #
  def all_liens_pages_cours arr_ids
    require_all_modules_of('page_cours')
    liens_edition_for_allin_ofclass(arr_ids, Unan::Program::PageCours)
  end

  def error_does_not_exist
    return if exist?
    raise "Le #{type} ##{id} n'existe pas, impossible d'obtenir ce que vous voulez."
  end
  def error_no_type_w
    return if type_w != nil
    raise "Le type_w de #{type}##{id} n'est pas défini… Impossible de le traiter."
  end
end

class Unan
class Program
class AbsWork

  include MethodesLinksProgramThings


  # Retourne le PDay absolu du travail courant
  # Note : Un seul pour un AbsWork
  def getof_pday
    error_does_not_exist

    res = search_pdays_where("works LIKE '%#{id}%'", [:works])

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
  # Pour qu'il existe, il faut que ce work soit de type questionnaire,
  # on prend alors son item_id
  def getof_quiz
    error_does_not_exist
    error_no_type_w
    if data_type_w[:id_list] == :quiz
      sub_log "Questionnaire ##{item_id.inspect} pour le work ##{id} de titre “#{titre}”."
      sub_log all_liens_quiz(item_id)
    else
      sub_log "Pas de quiz associé à ce work, il n'est pas de type-w questionnaire."
      false
    end
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  end

  # Retourne tous les exemples de cet AbsWork, s'il y en a
  def getof_exemple
    error_does_not_exist

  end

  # Retourne la page de cours associée à cet AbsWork, s'il
  # est associé à une page de cours
  def getof_page_cours
    error_does_not_exist
    error_no_type_w
    if data_type_w[:id_list] == :pages
      sub_log "Page de cours ##{item_id.inspect} pour le work ##{id} : #{titre}."
      sub_log all_liens_pages_cours(item_id)
    else
      sub_log "Pas de page de cours."
      false
    end
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  end


end #/AbsWork
end #/Program
end #/Unan
