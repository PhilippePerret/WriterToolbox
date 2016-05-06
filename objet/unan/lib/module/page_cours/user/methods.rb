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
    set_lue
    auteur.program.work(work_id).set_complete(!points_affected?)
    set_points_affected unless points_affected?
    flash "Page marquée lue."
  end

  def remarquer_a_lire
    auteur.program.work(work_id).set(ended_at: nil, status: 1)
    self.status= (self.status|BIT_LUE) -  BIT_LUE
    flash "Page re-marquée à lire."
  end

end #/UPage
end #/User
