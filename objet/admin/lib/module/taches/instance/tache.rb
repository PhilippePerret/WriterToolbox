# encoding: UTF-8
class Admin
class Todolist
class Tache

  include MethodesObjetsBdD

  attr_reader :id

  def initialize id = nil
    @id = id
  end

  def as_li
    (
      bouton_ok +
      boutons_edition +
      tache +
      echeance_humaine +
      admin_humain
    ).in_li(class:'tache')
  end

  def echeance_humaine
    @echeance_humaine ||= "Échoue le <strong>#{echeance.as_human_date}</strong>".in_span(class:'date')
  end
  def admin_humain
    @admin_humain ||= "Responsable : #{admin.pseudo}".in_span(class:'owner')
  end
  def bouton_ok
    "OK".in_a(href:"admin/todo_list?op=stop_tache&tid=#{id}").in_span(class:'btnok')
  end
  def boutons_edition
    @boutons_edition ||= begin
      (
        "[édit]".in_a(href:"admin/todo_list?op=edit_tache&tid=#{id}", class:'tiny' ) +
        "[–]".in_a(href:"admin/todo_list?op=destroy_tache&tid=#{id}", onclick:"if(confirm('Etes-vous certain de vouloir détruire cette tache plutôt que de la marquer finie ?')){return true}else{return false}", class:'tiny')
      ).in_div(class:'btns_edition')
    end
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def tache       ; @tache        ||= get(:tache)       end
  def echeance    ; @echeance     ||= get(:echeance)    end
  def admin_id    ; @admin_id     ||= get(:admin_id)    end
  def state       ; @state        ||= get(:state)       end
  def description ; @description  ||= get(:description) end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------
  def admin ; @admin ||= User::get(admin_id) end

  # ---------------------------------------------------------------------
  #   Méthodes
  # ---------------------------------------------------------------------
  def create
    @id = table.insert(data2save.merge(created_at:NOW))
    param(:todo => nil)
    flash "Tache ##{@id} créée avec succès."
  end
  # Actualisation de la donnée
  def update
    table.update(id, data2save)
    debug "data2save: #{data2save.pretty_inspect}"
    flash "Tache ##{id} actualisée."
  end
  def stop
    set( updated_at:NOW, state:9 )
  end
  def destroy
    table.delete( id )
  end
  def data2save
    @data2save ||= {
      tache:        data_param[:tache].nil_if_empty,
      admin_id:     data_param[:admin_id].to_i,
      description:  data_param[:description].nil_if_empty,
      echeance:     echeance_from_param,
      state:        1,
      updated_at:   NOW
    }
  end
  def echeance_from_param
    peche = data_param[:echeance]
    if peche.numeric?
      peche.to_i # Une ré-édition
    else
      jrs, mois, annee = peche.split(' ')
      Time.new(annee.to_i, mois.to_i, jrs.to_i).to_i
    end
  end
  def data_param
    @data_param ||= param(:todo)
  end

  def table
    @table ||= Admin::table_taches
  end

  # Return true si les données sont valides
  # Note : La méthode est utilisée par la console à la
  # création de la tâche, pour le moment.
  def data2save_valid?
    d = data2save
    d[:admin_id]  = test_admin_tache( d[:admin_id] || d.delete(:pour) || d.delete(:admin) ) || ( return false )
    d[:tache]     = test_task_tache( d[:tache] || d.delete(:faire) || d.delete(:task)) || (return false)
    d[:echeance]  = test_echeance_tache(d[:echeance] || d.delete(:le))
    return false if d[:echeance] === false
    d[:state]     = test_statut_tache(d[:state] || d.delete(:statut)) || ( return false )
    @data2save = d
  end


  # +aref+ pour "Référence administrateur", soit le pseudo soit l'id
  # de l'administrateur qui doit accomplir la tâche
  # La méthode retourne l'ID de l'administrateur ou génère une
  # error
  def test_admin_tache aref
    if aref.numeric?
      admin_id = aref.to_i
    else
      admin_id = User::table_users.select(where:"pseudo = '#{aref}'", colonnes:[]).keys.first
      raise "Aucun administrateur ne correspond au pseudo `#{aref}`" if admin_id.nil?
    end
    ua = User::get(admin_id)
    raise "L'user #{ua.pseudo} n'est pas administrateur…" unless ua.admin?
  rescue Exception => e
    debug e
    error e.message
  else
    return admin_id
  end

  # Vérifie la validité de la tache +action+, c'est-à-dire
  # ce qu'il y a vraiment à faire
  def test_task_tache act
    act = act.nil_if_empty
    raise "Il faut définir une action." if act.nil?
    act = act.sub(/^["“']/, '').sub(/["“']$/,'')
  rescue Exception => e
    debug e
    error e.message
  else
    return act
  end

  # Vérifie la validité de l'échéance définie et retourne
  # cette échéance sous forme de nombre de secondes
  # +eche+ Échéance String sous la forme "JJ MM AA" ou alors sous
  # un désignant comme "auj", "dem", "today", "aujourd'hui", etc.
  def test_echeance_tache eche
    return nil if eche.nil?
    eche = case eche
    when "auj", "today", "aujourd'hui" then
      Time.now.strftime("%d %m %Y")
    when "dem", "demain", "tomorrow" then
      (Time.now + 1.day).strftime("%d %m %Y")
    when "après-demain"
      (Time.now + 2.days).strftime("%d %m %Y")
    else
      eche
    end
    debug "eche transformé = #{eche.inspect}"
    jour, mois, annee = eche.split(' ').collect{ |e| e.to_i }
    if jour.nil? || mois.nil? || annee.nil?
      raise "L'échéance de la tâche doit être sous la forme JJ MM AA."
    end
    raise "Le jour de l'échéance doit être inférieur à 31" if jour > 31
    raise "Le mois doit être un nombre entre 1 et 12" if mois > 12 || mois < 1
    annee = 2000 + annee if annee < 100
    t = Time.new(annee, mois, jour)
    return t.to_i
  rescue Exception => e
    return error e.message
  end

  def test_statut_tache st
    return 0 if st.nil?
    raise "Le statut doit être un nombre." unless st.numeric?
    st = st.to_i
    raise "Le statut doit être supérieur à 0" if st < 0
    raise "Le statut ne doit pas être 9 — fini — à la création…" if st == 9
    raise "Le statut doit être inférieur à 9" if st > 8
  rescue Exception => e
    debug e
    return error e.message
  else
    return st
  end

end #/Tache
end #/Todolist
end #/Admin
