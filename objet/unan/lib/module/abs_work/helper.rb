# encoding: UTF-8
if user.admin?
  site.require_objet 'unan_admin'
  UnanAdmin::require_module 'abs_work'
end

class Unan
class Program
class AbsWork

  # ---------------------------------------------------------------------
  #   Propriétés au format humain
  # ---------------------------------------------------------------------

  def human_type_w
    @human_type_w ||= data_type_w[:hname]
  end

  def human_narrative_target
    @human_narrative_target ||= Unan::SujetCible::new(narrative_target).human_name
  end

  # ---------------------------------------------------------------------
  #   Builders HTML
  # ---------------------------------------------------------------------

  # {StringHTML} Retourne un lien permettant de lire le
  # travail.
  def lien_show titre_lien = nil, attrs = nil
    titre_lien ||= self.titre
    attrs ||= Hash::new
    ktype, context = ktype_and_context
    attrs.merge!(href: "#{ktype}/#{id}/show?in=#{context}")
    titre_lien.in_a(attrs)
  end

  def ktype_and_context
    return ['work', 'unan'] if data_type_w.nil? # c'est une erreur, mais bon
    case data_type_w[:id_list]
    when :pages then ['page_cours', 'unan']
    when :quiz  then ['quiz', 'unan']
    when :forum then ['post', 'forum']
    else # :tasks
      ['abs_work', 'unan']
    end
  end

  # Pour l'affichage du work sous forme de carte. Pour le moment,
  # ne sert que pour l'affichage du p-day par show.erb
  def as_card params = nil
    (
      (
        human_type_w.in_span(class:'type') +
        titre.in_span(class:'titre')
      ).in_div(class:'div_titre') +
      div_travail +
      autres_infos_travail +
      buttons_edit
    ).in_div(class:'work')
  end

  def div_travail
    item_link = if item_id
      chose, human_chose = case true
      when page_cours?  then ['page_cours', "la page de cours"]
      when quiz?        then ['quiz', "le questionnaire"]
      when forum?       then ['forum', "le message forum"]
      else ['task', "tâche"]
      end
      " (voir #{human_chose} ##{item_id})".in_a(href:"#{chose}/#{item_id}/show?in=unan", target:"_show_#{chose}_")
    else
      ""
    end
    (
      travail + item_link
    ).in_div(class:'travail')
  end
  def autres_infos_travail
    s_duree = duree > 1 ? "s" : ""
    (
      ("Type projet :".in_span(class:'libelle') + type_projet[:hname]).in_span(class:'info') +
      ("Sujet :".in_span(class:'libelle') + "#{human_narrative_target}").in_span(class:'info') +
      ("Durée :".in_span(class:'libelle') + "#{duree}#{ESPACE_FINE}jour#{s_duree}-programme").in_span(class:'info') +
      ("Points :".in_span(class:'libelle') + "#{points}".in_span).in_span(class:'info')
    ).in_div(class:'autres_infos')
  end
  def buttons_edit
    return "" unless user.admin?
    (
      lien_edit("[Edit Work##{id}]")
    ).in_div(class:'right tiny')
  end

end #/AbsWork
end #/Program
end #/Unan
