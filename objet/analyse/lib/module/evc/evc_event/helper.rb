# encoding: UTF-8
class Evc
class Event

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------

  # {StringHTML} Ligne de l'évènement pour affichage
  # +options+
  #     duree:      Si true, on ajoute la durée si elle définie
  #     notes:      Si true, on ajoute les notes qui existent
  def as_li options = nil
    options ||= Hash::new
    li = ""
    li << human_time.in_span(class:'h') # li.ev span.h
    if options[:duree]
      # Noter qu'on l'inscrit toujours, pour respecter
      # les espaces
      li << human_duree.in_span(class:'d') # li.ev span.d
    end
    li << resume.in_span(class:'r') # li.ev span.r
    li.in_li(class:'ev')
  end

  def human_time
    @human_time ||= begin
      if horloge.nil?
        ""
      elsif in_page?
        "p. #{horloge}"
      else # in_seconde?
        time.as_horloge
      end
    end
  end
  def human_duree
    @human_duree ||= begin
      duree.nil? ? "" : duree.as_duree
    end
  end

end #/Event
end #/Evc
