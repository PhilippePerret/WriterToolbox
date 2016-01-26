# encoding: UTF-8
class User
class UPage

  # Statut de la page
  BIT_VUE = 1
  BIT_LUE = 2
  BIT_TDM = 4
  BIT_PTS = 8   # Ajouté si la page a marqué ses points

  # Retourne true si la page existe pour l'user
  def exist?    ; table.count(where:{id: id}) > 0 end

  
  # Retourne true si la page a été marquée vue
  def vue?      ; status & BIT_VUE > 0  end
  def not_vue?  ; false == vue?         end
  # Retourne true si la page a été marquée lue
  def lue?      ; status & BIT_LUE > 0  end
  def not_lue?  ; false == lue?         end
  # Retourne true si la page se trouve dans la table des
  # matières de l'auteur
  def tdm?      ; status & BIT_TDM > 0  end
  alias :in_tdm? :tdm?

  # Retourne true si les points ont déjà été affectés
  def points_affected?
    status & BIT_PTS > 0
  end
  def set_vue
    self.status= (status | BIT_VUE)
  end
  def set_lue
    self.status= (status | BIT_LUE)
  end
  def set_in_tdm
    self.status= (status | BIT_TDM)
  end
  def set_points_affected
    self.status= (status | BIT_PTS)
  end

end #/UPage
end #/User
