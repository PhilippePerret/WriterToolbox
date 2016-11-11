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
    scenes.each do |hscene|
      sid = hscene[:id]
      new_brins = param("scene-#{sid}-brins".to_sym).split(' ').collect{|n| n.to_i}
      if new_brins != hscene[:brins_ids]
        # debug "Changement : #{hscene[:brins_ids].inspect} -> #{new_brins.inspect}"
        hscene[:brins_ids] = new_brins
        modified = true
      end
    end
    modified || return
    # S'il y a eu des changements, il faut les enregistrer dans le
    # fichier marshal, et il faut aussi proposer de refaire le fichier de
    # données déposées.
    scenes_file.write( Marshal.dump(scenes) )
  end

end #/AnalyseBuild
