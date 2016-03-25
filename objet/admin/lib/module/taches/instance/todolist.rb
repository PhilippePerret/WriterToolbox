# encoding: UTF-8
class Admin
class Todolist

  # L'administrateur qui possède cette liste
  # Si défini, la todolist le concernera lui seulement.
  attr_reader :admin_id

  # = Instanciation =
  # +data+
  #   :admin_id     Le propriétaire de cette liste.
  #
  def initialize data = nil
    data ||= Hash::new
    @admin_id = data.delete(:admin_id)
  end

  def list_taches admin_current = true
    if admin_current
      liste_taches_admin_courant
    else
      liste_taches_autres_admins
    end
  end

  def liste_taches_admin_courant
    @liste_taches_admin_courant || liste_des_taches_dispatched
    @liste_taches_admin_courant
  end

  def liste_taches_autres_admins
    @liste_taches_autres_admins || liste_des_taches_dispatched
    @liste_taches_autres_admins
  end

  def liste_des_taches_dispatched
    @ladmin = Array::new
    @lothers = Array::new
    Admin::table_taches.select(where:'state < 9',order:"echeance ASC",colonnes:[:admin_id]).each do |tid, tdata|
      owned_current = tdata[:admin_id] == admin_id
      itache = Tache::new(tid)
      itache.get_all
      litache = itache.as_li
      owned_current ? (@ladmin << litache) : (@lothers << litache)
    end
    @liste_taches_admin_courant = @ladmin.join.in_ul(class:'taches')
    @liste_taches_autres_admins = @lothers.join.in_ul(class:'taches')
  end

  # Liste {Array} des instances Tache de la liste
  def taches options = nil
    @taches = nil if options != nil
    @taches ||= begin
      options ||= Hash::new
      where = options[:where] || "state < 9"
      where += " AND admin_id = #{admin_id}" unless admin_id.nil?
      options.merge!(where: where)
      options.merge!(order:"echeance ASC")  unless options.has_key?(:order)
      options.merge!(colonnes:[])           unless options.has_key?(:colonnes)
      Admin::table_taches.select(options).collect { |tid, tdata| Tache::new(tid) }
    end
  end

end #/ Todolist
end #/ Admin
