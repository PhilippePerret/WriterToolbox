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
  def not_vue?  ; false == vue?         end
  # Retourne true si la page a été marquée lue
  def lue?      ; exist? ? (status & BIT_LUE > 0) : false  end
  def not_lue?  ; false == lue?         end
  # Retourne true si la page se trouve dans la table des
  # matières de l'auteur
  def tdm?      ; exist? ? (status & BIT_TDM > 0) : false end
  alias :in_tdm? :tdm?

  # Retourne true si les points ont déjà été affectés
  def points_affected?  ; exist? ? (status & BIT_PTS > 0) : false end
  def set_lue
    create unless exist?
    self.status= (status | BIT_LUE)
  end
  def set_in_tdm
    create unless exist?
    self.status= (status | BIT_TDM)
  end
  def set_points_affected
    create unless exist?
    self.status= (status | BIT_PTS)
  end

  # La méthode pour marquer une page vue est spéciale dans le
  # sens où elle doit :
  #   - créer l'instance work qui la concerne (car marquer une page
  #     de cours "vue" correspond à démarrer le travail)
  def set_vue
    create unless exist?
    # On commence par marquer simplement cette page comme vue
    self.status= (status | BIT_VUE)
    # Ensuite, il faut trouver toutes les données qui permettront
    # de créer un nouveau travail (Unan::Program::Work) pour cette
    # page et pour l'auteur.
    # L'ID de cette page est le même que l'ID de la page_cours associée
    # au travail. Donc on recherche un travail qui a pour item_id cet
    # ID de page et pour type_w 20 ou 21 (page à lire ou relire)
    where = "item_id = #{id} AND type_w IN (20,21)"
    awork_ids = Unan::table_absolute_works.select(where: where, colonnes: []).collect{|h|h[:id]}
    debug "awork_ids : #{awork_ids}"
    # Il faut ensuite connaitre l'indice p-day pour pouvoir l'enregistrer
    # dans le work. Pour trouver cet indice on doit trouver le PDay qui
    # a awork_id dans ses "works". Mais comme il peut être utilisé plusieurs
    # fois, on choisit le premier à partir du pday courant de l'auteur
    curpday = auteur.program.current_pday
    where = "works LIKE '%#{awork_ids[0]}%'"
    if awork_ids.count > 1
      where = "(#{where} OR works LIKE '%#{awork_ids[1]}%')"
    end
    data_req = Hash::new
    data_req.merge!( where: "id <= #{curpday} AND #{where}" )
    data_req.merge!( order: "id ASC" )
    data_req.merge!( colonnes: [:works] )
    awork_id = nil
    apday_id = nil
    Unan::table_absolute_pdays.select(data_req).each do |pdata|
      pid = pdata[:id]
      next if pdata[:works].nil?
      wids = pdata[:works].split(' ').collect{ |e| e.to_i }
      if wids.include?(awork_ids[0])
        awork_id = awork_ids[0].freeze  # le dernier est forcément le bon
        apday_id = pid.freeze           # item
      elsif awork_ids[1] && wids.include?(awork_ids[1])
        awork_id = awork_ids[1].freeze  # le dernier est forcément le bon
        apday_id = pid.freeze           # item
      end
    end
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
    debug "ID du work créé :  #{iwork.id}"
    return iwork
  end


end #/UPage
end #/User
