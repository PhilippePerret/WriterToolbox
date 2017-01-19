# encoding: UTF-8
=begin
Helper de liens pour la collection

Pour les utiliser dans les pages utiliser :

    <%= lien.livre_<le livre> %>

=end
class Lien

  def livre_la_structure
    link_livre_id Cnarration::SYM2ID[:structure]
  end
  def livre_les_personnages
    link_livre_id Cnarration::SYM2ID[:personnages]
  end
  def livre_la_dynamique_narrative
    link_livre_id Cnarration::SYM2ID[:dynamique]
  end
  def livre_la_thematique
    link_livre_id Cnarration::SYM2ID[:thematique]
  end
  def livre_les_documents
    link_livre_id Cnarration::SYM2ID[:documents]
  end
  def livre_le_travail_de_lauteur
    link_livre_id Cnarration::SYM2ID[:travail_auteur]
  end
  def livre_les_procedes
    link_livre_id Cnarration::SYM2ID[:procedes]
  end
  def livre_les_concepts_narratifs titre = nil
    link_livre_id Cnarration::SYM2ID[:concepts_narratifs], titre
  end
  def livre_le_dialogue
    link_livre_id Cnarration::SYM2ID[:dialogue]
  end
  def livre_lanalyse_de_films
    link_livre_id Cnarration::SYM2ID[:analyse]
  end
  def livre_exemples
    link_livre_id Cnarration::SYM2ID[:exemples]
  end

  def link_livre_id livre_id, titre = nil
    dlivre = Cnarration::LIVRES[livre_id]
    case output_format
    when :latex
      "#{titre || dlivre[:hname]}\\cite{NarrationID#{livre_id}}"
    else
      (titre || dlivre[:hname]).in_a(class:'livre', href:"livre/#{livre_id}/tdm?in=cnarration")
    end
  end


end
