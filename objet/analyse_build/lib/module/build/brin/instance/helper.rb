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
          element = chantier.scene(psid)
          "Scène #{psid}"
        when String
          element = chantier.paragraphe(psid)
          "Paragraphe #{psid}"
        end.in_div(class:'ev')
      end.join('').in_div(class: 'brin_events')
    titre.in_div(class:'brin_titre') +
    liste_events
  end

end #/Brin
end #/Film
end #/AnalyseBuild
