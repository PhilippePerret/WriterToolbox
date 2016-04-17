# encoding: UTF-8
=begin

 - HTML -

Contient les méthodes de correction pour la sortie HTML des
fichier de la collection Narration (et plus généralement pour
tout fichier markdown/kramdown).

=end

class Cnarration
class Translator

  def pre_corrections
    suivi << "    -> pré-corrections"

  end

  def post_corrections
    suivi << "    -> post-corrections"

  end

  # Finalisation du contenu du fichier
  def finalise_content

  end

end #/Translator
end #/Cnarration
