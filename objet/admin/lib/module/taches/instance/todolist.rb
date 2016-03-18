# encoding: UTF-8
class Admin
class Todolist

    def list_taches
      taches.collect do |tache|
        tache.get_all
        tache.as_li
      end.join.in_ul(id:'taches')
    end

    # Liste des instances Tache de la liste
    def taches
      @taches ||= begin
        Admin::table_taches.select(where: "state < 9", order:"echeance ASC", colonnes:[]).collect do |tid, tdata|
          Tache::new(tid)
        end
      end
    end

end #/ Todolist
end #/ Admin
