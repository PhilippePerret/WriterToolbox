# encoding: UTF-8
class Unan
class Histo

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------
  def as_ul
    auteur.uworks_done.collect do |pairid, hwork|
      awork_id, pday = pairid.split('-').collect{|x|x.to_i}
      Unan::Program::AbsWork.new(awork_id).as_card(hwork.merge(auteur: auteur))
    end.reverse.join.in_ul(id: 'historique')
  end

  def auteur
    @auteur ||= user
  end

  # ---------------------------------------------------------------------
  #   Méthodes administrateur
  # ---------------------------------------------------------------------
  if user.admin?
    def auteur= value; @auteur = value end
  end

end #/Histo

class Program
class AbsWork

  # {Hash} des données du travail particulier de l'auteur, transmises
  # à la méthode `as_card`
  attr_reader :work_data

  # Méthode qui surclasse toutes les autres méthodes, elle doit être
  # capable de produire une carte pour n'importe quel type de travail
  # +work_data+ contient les données du travail propre à l'auteur
  def as_card work_data
    @work_data = work_data
    (
      div_titre +
      div_infos_in_card
    ).in_li(class: 'work', id: "li_work-#{id}")
  end

  def div_titre
    (
      Time.at(work_data[:created_at]).strftime("%d %m %Y").in_span(class: 'horloge') +
      titre.in_span(class: 'titre')
    ).in_div(class:'div_titre')
  end
  def div_infos_in_card
    start = work_data[:created_at].as_human_date(true, true, ' ', 'à')
    stop  = work_data[:ended_at].as_human_date(true, true, ' ', 'à')
    span_points =
      if work_data[:points]
        'Points' + work_data[:points].to_s.in_span(class: 'points')
      else '' end
    (
      'démarré le' + start.in_span(class: 'wstart') +
      'achevé le' + stop.in_span(class: 'wstop') +
      span_points
    ).in_div(class: 'infos')
  end
end #/AbsWork
end #/Program
end #/Unan

def historique
  @historique ||= Unan::Histo.new
end
