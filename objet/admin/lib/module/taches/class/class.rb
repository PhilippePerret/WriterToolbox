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

end #/Todolist
end #/Admin
