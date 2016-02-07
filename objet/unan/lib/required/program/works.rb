# encoding: UTF-8
=begin
Extension des instance Unan::Program pour gérer les instances
Work du programme
=end
class Unan
class Program

  # {Unan::Program::Work} Retourne l'instance d'identifiant +wid+
  # du Work du programme courant, ou nil si elle n'existe pas
  def work wid
    wid = wid.nil_if_empty.to_i_inn
    return nil if wid.nil?
    Work::get(self, wid)
  end

  # {Array of Hash} Liste des travaux propres du
  # programme courant en appliquant le filtre +filtre+ s'il est
  # défini. Noter que les travaux sont toujours en ordre inverse,
  # les derniers en premier.
  # +filtre+
  #   :completed    Si true, les travaux terminés (status 9)
  #                 Si false, seulement les non terminés
  #   :type         Le type, parmi :task, :quiz, :pages (cours)
  #                 :forum.
  #   :count        {Fixnum} Pour ne récupérer qu'un certain nombre
  #                 de tâche. Par exemple, pour les 10 dernières :
  #                 filtre = {completed:true, count:10}
  def works filtre = nil
    @works ||= self.table_works.select(order:"created_at DESC").values
    return @works if filtre.nil?

    filtered = @works.dup

    # Filtrage pour ne prendre que les works terminés (ou pas)
    if ( filtre.has_key? :completed )
      if filtre[:completed]
        filtered.select! { |h| h[:status] == 9 }
      else
        filtered.select! { |h| h[:status] < 9 }
      end
    end

    # Filtrage pour ne prendre que les works d'un
    # certain type
    if filtre[:type]
      filtre[:type] = case filtre[:type]
      when :task then :tasks
      when :page then :pages
      else filtre[:type]
      end
      liste_codes_type = Unan::Program::AbsWork::CODES_BY_TYPE[filtre[:type]]
      filtered.select! do |h|
        liste_codes_type.include?(Unan::Program::AbsWork::get(h[:abs_work_id]).type_w)
      end
    end

    # Filtrage pour ne prendre que les x derniers
    if filtre[:count]
      filtered = filtered[0..filtre[:count] - 1]#.compact
    end

    filtered
  end

  # {Array of Unan::Program::Work} Retourne les 5 dernières tâches
  # comme instance.
  def last_tasks
    @last_tasks ||= begin
      works(completed:true, count:5, type: :task).collect do |hwork|
        Work::new(self, hwork[:id])
      end
    end
  end

end #/Program
end #/Unan
