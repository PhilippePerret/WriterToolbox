# encoding: UTF-8
raise_unless_admin
Admin::require_module 'taches'

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
