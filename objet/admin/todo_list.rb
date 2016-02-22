# encoding: UTF-8
raise_unless_admin
class Admin
class Todolist

  class << self
    def get tache_id
      tache_id = tache_id.to_i
      @instances ||= Hash::new
      @instances[tache_id] ||= Tache::new(tache_id)
    end
  end # << self

  def list_taches
    taches.collect do |tache|
      tache.get_all
      tache.as_li
    end.join.in_ul(id:'taches')
  end

  # Liste des instances Tache de la liste
  def taches
    @taches ||= begin
      Admin::table_taches.select(order:"echeance ASC", colonnes:[]).collect do |tid, tdata|
        Tache::new(tid)
      end
    end
  end

  # ---------------------------------------------------------------------
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
    def tache     ; @tache    ||= get(:tache)     end
    def echeance  ; @echeance ||= get(:echeance)  end
    def admin_id  ; @admin_id ||= get(:admin_id)  end

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
  end
end #/Todolist
end #/Admin


def todolist
  @todolist ||= Admin::Todolist::new()
end

def tache_id
  @tache_id ||= param(:tid).to_i_inn
end

if tache_id != nil
  case param(:op)
  when 'edit_tache'
    form.objet = Admin::Todolist::Tache::new(tache_id)
  when 'stop_tache'
    Admin::Todolist::Tache::new(tache_id).stop
  when 'destroy_tache'
    Admin::Todolist::Tache::new(tache_id).destroy
  end
else
  case param(:operation)
  when 'save_tache'
    if param(:todo)[:id].nil?
      Admin::Todolist::Tache::new().create
    else
      Admin::Todolist::Tache::new(param(:todo)[:id].to_i).update
    end
  end
end
