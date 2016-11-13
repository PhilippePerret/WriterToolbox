# encoding: UTF-8
class AnalyseBuild

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
    save_scenes
  end

end #/AnalyseBuild
