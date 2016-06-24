# encoding: UTF-8
class User
class UPage


  # La méthode pour marquer une page vue est spéciale dans le
  # sens où elle doit :
  #   - créer l'instance work qui la concerne (car marquer une page
  #     de cours "vue" correspond à démarrer le travail)
  def set_vue
    create unless exist?
    # On commence par marquer simplement cette page comme vue
    self.status= (status | BIT_VUE)

    # On prend l'identifiant du work absolu et le jour-programme
    # correspondant à la page dans les paramètres.
    awork_id = param(:awid).to_i
    apday_id = param(:pday).to_i

    # Les données doivent avoir été spécifiées
    awork_id > 0 || raise('L’ID du travail absolu doit être spécifié pour marquer la page vue.')
    apday_id > 0 || raise('Le jour-programme doit être spécifié pour marquer la page vue.')

    # debug "ID d'absolute work : #{awork_id}"
    # debug "ID de PDay trouvé : #{apday_id}"
    # On a maintenant toutes les données nécessaires pour créer
    # le travail. On charge le module qui le fait
    require './objet/unan/lib/module/work/create.rb'
    iwork = create_new_work_for_user(
      user:         auteur,
      abs_work_id:  awork_id,
      indice_pday:  apday_id
    )
    # Mémoriser ce travail pour cet page
    set( :work_id => iwork.id )
    # debug "ID du work créé :  #{iwork.id}"
    return iwork
  end

  # Marque la page comme lue
  # ------------------------
  # Cela la passe au statut 3 (status) et la retire des :pages_ids de
  # l'auteur si elle s'y trouve
  # Note : Cette méthode se trouve ici et non pas seulement dans
  # le panneau des pages à lire par l'auteur car on peut marquer une
  # page lue depuis les pages elles-mêmes.
  def set_lue
    self.status= (status | BIT_LUE)
    auteur.program.work(work_id).set_complete( !points_affected? )
    points_affected? || set_points_affected
    flash "Page marquée lue."
  end

  def set_a_relire
    auteur.program.work(work_id).set(ended_at: nil, status: 1)
    self.status= (self.status|BIT_LUE) -  BIT_LUE
    flash "Page re-marquée à lire."
  end

  # ---------------------------------------------------------------------
  #   Sous-méthodes
  # ---------------------------------------------------------------------

  def set_in_tdm
    self.status= (status | BIT_TDM)
  end
  def set_points_affected
    create unless exist?
    self.status= (status | BIT_PTS)
  end

end #/UPage
end #/User
