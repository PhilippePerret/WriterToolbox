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

  def list_taches
    taches.collect do |tache|
      tache.get_all
      tache.as_li
    end.join.in_ul(id:'taches')
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
