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
    end.join.in_ul(id: 'historique')
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
      div_infos_cachees +
      div_infos_in_card
    ).in_li(class: 'work', id: "li_work-#{id}")
  end

  def div_titre
    (
      div_boutons_aperus +
      Time.at(work_data[:created_at]).strftime("%d %m %Y").in_span(class: 'horloge') +
      "##{id} #{titre}".in_span(class: 'titre')
    ).in_div(class:'div_titre')
  end
  def div_boutons_aperus
    (
      'voir'.in_a(onclick:'UnanHisto.show(this)', 'data-id' => "#{id}")
    ).in_div(class: 'apercu')
  end
  def div_infos_cachees
    (
      "#{travail}#{associated_item}".in_div(class: 'w') +
      div_exemples
    ).in_div(class: 'hinfos masked')
  end
  # Span pour l'item associé au travail s'il existe. Ce peut être un
  # quiz, une page de cours, etc.
  def associated_item
    item_id || (return '')
    case true
    when quiz?
      # debug "work_data : #{work_data.inspect}"
      href =  "quiz/#{item_id}/reshow?qdbr=unan"
      work_data[:item_id] && href += "&qresid=#{work_data[:item_id]}"
      " Voir le quiz ##{item_id}".in_a(href: href)
    when page_cours?
      hpage = Unan.table_pages_cours.get(item_id)
      href =
        if hpage[:narration_id]
          # => Page de la collection Narration
          "narration/#{hpage[:narration_id]}/show"
        else
          # => Page de cours réservée au programme
          "page_cours/#{item_id}/show?in=unan"
        end
      " #{hpage[:titre]}".in_a(href: href)
    end
  end
  def div_exemples
    exemples || (return '')
    exemples.split(' ').collect do |eid|
      "Exemple #{eid}".in_a(href: "exemple/#{eid}/show?in=unan")
    end.join(', ').in_div(class: 'exs')
  end
  def div_infos_in_card
    start = work_data[:created_at].as_human_date(true, true, ' ', 'à')
    stop  = work_data[:ended_at].as_human_date(true, true, ' ', 'à')
    (
      'démarré le' + start.in_span(class: 'wstart') +
      'achevé le' + stop.in_span(class: 'wstop') +
      span_points
    ).in_div(class: 'infos')
  end
  def span_points
    work_data[:points] || (return '')
    'Points :' + work_data[:points].to_s.in_span(class: 'points')
  end
end #/AbsWork
end #/Program
end #/Unan

def historique
  @historique ||= Unan::Histo.new
end
