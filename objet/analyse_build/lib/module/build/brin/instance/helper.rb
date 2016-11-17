# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Brin

  # Un brin comme liste simple
  #
  def as_simple_list
    liste_events =
      para_or_scene_ids.collect do |psid|
        # Note : `psid` peut être soit un Fixnum (numéro d'une scène),
        # soit un String ("numéro scène:id de paragraphe")
        case psid
        when Fixnum
          # Une scène
          element = chantier.scene(psid)
        when String
          # Un paragraphe de scène
          element = chantier.paragraphe(psid)
        end
        element.as_brin_event.in_li(class:'bev')
      end.join('')

    (
      titre.in_div(class:'brin_titre') +
      liste_events.in_ul(class: 'brin_events')
    ).in_div(class: 'simple_brin')
  end

end #/Brin
end #/Film
end #/AnalyseBuild
