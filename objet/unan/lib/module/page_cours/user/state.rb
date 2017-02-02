# encoding: UTF-8
class User
class UPage

  # Statut de la page
  BIT_VUE = 1
  BIT_LUE = 2
  BIT_TDM = 4
  BIT_PTS = 8   # Ajouté si la page a marqué ses points

  # Retourne true si la page existe pour l'user
  def exist?
    @is_exist = table.count(where:{id: id}) > 0 if @is_exist === nil
    @is_exist
  end


  # Retourne true si la page a été marquée vue
  def vue?      ; exist? ? (status & BIT_VUE > 0) : false  end
  def not_vue?  ; !vue? end
  # Retourne true si la page a été marquée lue
  def lue?      ; exist? ? (status & BIT_LUE > 0) : false  end
  def not_lue?  ; !lue? end
  # Retourne true si la page se trouve dans la table des
  # matières de l'auteur
  def tdm?      ; exist? ? (status & BIT_TDM > 0) : false end
  alias :in_tdm? :tdm?

  # Retourne true si les points ont déjà été affectés
  def points_affected?  ; exist? ? (status & BIT_PTS > 0) : false end

end #/UPage
end #/User
