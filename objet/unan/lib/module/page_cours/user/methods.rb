# encoding: UTF-8
class User
class UPage

  # Marque la page comme lue
  # ------------------------
  # Cela la passe au statut 3 (status) et la retire des :pages_ids de
  # l'auteur si elle s'y trouve
  # Note : Cette méthode se trouve ici et non pas seulement dans
  # le panneau des pages à lire par l'auteur car on peut marquer une
  # page lue depuis les pages elles-mêmes.
  def marquer_lue
    self.set_lue
    # Marquer le travail terminé (ce qui le retirera des listes
    # d'identifiants)
    wids.each do |wid|
      work = auteur.program.work(wid)
      if work.abs_work.item_id == id
        # Est-ce qu'il faut ajouter les points, où ont-ils déjà
        # été attribués au cours d'une autre lecture.
        must_add_point = if self.points_affected?
          false
        else
          set_points_affected
          true
        end
        work.set_complete(must_add_point)
        break
      end
    end
    flash "Page marquée lue."
  end

  def remarquer_a_lire
    work_id = nil
    where = "ended_at IS NOT NULL"
    auteur.table_works.select(where:where, colonnes: [:abs_work_id]).each do |wid, wdata|
    # auteur.table_works.select(colonnes: [:abs_work_id]).each do |wid, wdata|
      debug "wdata: #{wdata.inspect}"
      aw = Unan::Program::AbsWork::get(wdata[:abs_work_id])
      if [20,21].include?(aw.type_w) && aw.item_id == id
        work_id = wid.freeze
        Unan::Program::Work::new(auteur, work_id).set(ended_at: nil)
        break
      end
    end
    return error "Impossible de trouver le travail absolu de cette page de cours…" if work_id.nil?
    wids = auteur.get_var(:works_ids, Array::new)
    pids = auteur.get_var(:pages_ids, Array::new)
    unless wids.include?(work_id)
      wids << work_id
      auteur.set_var(works_ids: wids)
    end
    unless pids.include?(work_id)
      pids << work_id
      auteur.set_var(pages_ids: pids)
    end
    # Et on passe le statut à 1
    self.status= (self.status|BIT_LUE) -  BIT_LUE
    flash "Page re-marquée à lire."
  end

end #/UPage
end #/User
