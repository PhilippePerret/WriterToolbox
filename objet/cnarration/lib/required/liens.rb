# encoding: UTF-8
=begin
Helper de liens pour la collection

Pour les utiliser dans les pages utiliser :

    <%= lien.livre_<le livre> %>

=end
class Lien

  def livre_la_structure autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:structure], autre_titre
  end
  alias :livre_structure :livre_la_structure
  def livre_les_personnages autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:personnages], autre_titre
  end
  alias :livre_personnages :livre_les_personnages
  def livre_la_dynamique_narrative autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:dynamique], autre_titre
  end
  alias :livre_dynamique :livre_la_dynamique_narrative
  def livre_la_thematique autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:thematique], autre_titre
  end
  alias :livre_thematique :livre_la_thematique
  def livre_les_documents autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:documents], autre_titre
  end
  alias :livre_documents :livre_les_documents
  def livre_le_travail_de_lauteur autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:travail_auteur], autre_titre
  end
  alias :livre_auteur :livre_le_travail_de_lauteur
  alias :livre_travail_auteur :livre_le_travail_de_lauteur
  def livre_les_procedes autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:procedes], autre_titre
  end
  alias :livre_procedes :livre_les_procedes
  def livre_les_concepts_narratifs titre = nil
    link_livre_id Cnarration::SYM2ID[:concepts_narratifs], titre
  end
  alias :livre_concepts :livre_les_concepts_narratifs
  def livre_le_dialogue autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:dialogue], autre_titre
  end
  def livre_lanalyse_de_films autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:analyse], autre_titre
  end
  alias :livre_analyse :livre_lanalyse_de_films
  alias :livre_analyse_film :livre_lanalyse_de_films
  def livre_exemples autre_titre = nil
    link_livre_id Cnarration::SYM2ID[:exemples], autre_titre
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
