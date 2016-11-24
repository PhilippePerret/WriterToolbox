# encoding: UTF-8
class AnalyseBuild

  # Méthode principale appelée pour définir les brins, c'est-à-dire
  # dans quelles scènes se trouvent tous les brins ou toutes les scènes
  # de chaque brin.
  #
  # Cette méthode prend en compte les modifications qui ont été faites et
  # les enregistre dans le fichier de données Marshal (qui va être bloqué
  # pour ne plus pouvoir être modifié)
  def define_brins
    # Ici, on ne fait rien. C'est le formulaire pour définir les
    # brins de chaque scène qui sera affiché dans une page bloquée.
  end

  def save_brins_of_scenes
    modified = false

    # Traitement de chaque scène
    # Et à l'intérieur de chaque scène, chaque paragraphe sera
    scenes.each do |hscene|
      sid = hscene[:numero]
      new_brins = param("scene-#{sid}-brins".to_sym).split(' ').collect{|n| n.to_i}
      if new_brins != hscene[:brins]
        # debug "Changement : #{hscene[:brins].inspect} -> #{new_brins.inspect}"
        hscene[:brins] = new_brins
        modified = true
      end
      hscene[:data_paragraphes].each do |dparagraphe|
        para_id = "paragraphe-#{dparagraphe[:id].sub(/:/,'_')}-brins".to_sym
        new_brins_parag = param(para_id).split(' ').collect{|n|n.to_i}
        if new_brins_parag != dparagraphe[:brins]
          dparagraphe[:brins] = new_brins_parag
          modified = true
        end
      end
    end
    modified || return

    # S'il y a eu des changements, il faut les enregistrer dans le
    # fichier marshal, et il faut aussi proposer de refaire le fichier de
    # données déposées.
    scenes_file.write( Marshal.dump(scenes) )
    flash "Nouvelles données scènes & paragraphes enregistrées."

    # Il faut également actualiser les données des brins développées
    AnalyseBuild.require_module 'developpe_data'
    chantier.set_paragraphes_of_brins
    flash "Le développement des brins a été actualisé."

  end

end #/AnalyseBuild
