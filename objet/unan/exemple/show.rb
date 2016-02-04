# encoding: UTF-8
raise_unless user.unanunscript? || user.admin?

Unan::require_module 'exemple'

class Unan
class Program
class Exemple

  # {StringHTML} Retourne le code HTML pour afficher l'exemple
  # sous le format défini par +as+
  # Noter qu'on joue surtout sur les styles CSS pour donner les
  # différents aspects.
  # +as+
  #   :fullcard (par défaut) L'exemple avec toutes ses informations
  #   :simple     Seulement l'exemple
  def as_card as = :fullcard
    (
      div_titre   +
      div_notes   +
      div_content +
      div_infos
    ).in_div(id:"xpl-#{id}", class:"xpl #{as}")
  end

  def div_titre
    titre.in_div(class:'titre')
  end
  def div_notes
    return "" if notes.empty?
    notes.in_div(class:'notes')
  end
  def div_content
    content.in_div(class:'content')
  end
  def div_infos
    (
      "Exemple tiré de".in_span(class:'libelle') + source   +
      "sujet".in_span(class:'libelle')   + sujet_humain      +
      "année".in_span(class:'libelle')   + source_year.to_s  +
      "créé le".in_span(class:'libelle') + created_at.as_human_date
    ).in_div(class:'infos')
  end

  def sujet_humain
    @sujet_humain ||= Unan::SujetCible::new(sujet).human_name
  end


end #/Exemple
end #/Program
end #/Unan

# {Unan::Program::Exemple} Retourne l'instance de l'exemple à
# afficher (noter qu'il peut y en avoir plusieurs à afficher sur
# la même page)
def exemple
  @exemple ||= begin
    exemple_id.nil? ? nil : Unan::Program::Exemple::get( exemple_id )
  end
end
def exemple_id
  @exemple_id ||= begin
    if param(:exid)
      param(:exid).to_i
    elsif param(:exemple_id)
      param(:exemple_id).to_i
    elsif site.current_route.objet == 'exemple' && site.current_route.objet_id != nil
      site.current_route.objet_id
    else
      nil
    end
  end
end
