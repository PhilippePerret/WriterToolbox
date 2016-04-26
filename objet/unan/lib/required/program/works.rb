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

  # Retourne les travaux courants (i.e. non finis) dans le format
  # :as voulu
  # Rappel : Un travail courant est un travail qui a
  #   - le status inférieur à 9
  #   - ET la date de création inférieur à NOW (*)
  #
  # (*) Les travaux qui ont un created_at supérieur à NOW sont
  #     des travaux reprogrammés.
  def current_works options = nil
    options ||= Hash::new
    options[:as] ||= :data
    @works_hash ||= self.table_works.select(where:"status < 9 AND created_at < #{NOW + 1}")

    case options[:as]
    when :data then @works_hash.values
    when :id, :ids then @works_hash.keys
    when :instance, :instances
      @works_hash.keys.collect { |wid| Work::get(self, wid) }
    else
      @works_hash
    end
  end

  # Retourne la liste des travaux futurs
  # +options+ définit principalement :as, le format de retour des
  # éléments du Array qui est retourné (cf. ci-dessus la méthode
  # current_works)
  def ulterieurs_works options = nil
    options ||= Hash::new
    options[:as] ||= :data
    @ulterieurs_works ||= self.table_works.select(where:"created_at > #{NOW}")

    case options[:as]
    when :data then @ulterieurs_works.values
    when :id, :ids then @ulterieurs_works.ids
    when :instance, :instances
      @ulterieurs_works.keys.collect{ |wid| Work::get(self, wid) }
    else
      @ulterieurs_works
    end
  end

  # {Array of Hash} Liste des travaux propres du
  # programme courant en appliquant le filtre +filtre+ s'il est
  # défini. Noter que les travaux sont toujours en ordre inverse,
  # les derniers en premier.
  #
  # @usage    <auteur>.program.works
  # +filtre+
  #   :completed    Si true, les travaux terminés (status 9)
  #                 Si false, seulement les non terminés
  #   :type         Le type, parmi :task, :quiz, :pages (cours)
  #                 :forum.
  #   :count        {Fixnum} Pour ne récupérer qu'un certain nombre
  #                 de tâche. Par exemple, pour les 10 dernières :
  #                 filtre = {completed:true, count:10}
  #
  # Noter que les travaux futur (avec un created_at supérieur à NOW)
  # seront aussi traités par cette méthode.
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
      type_task_ids = Unan::Program::AbsWork::CODES_BY_TYPE[:tasks]
      where_clause = "status = 9"
      # Je relève les 20 derniers travaux (work) de l'auteur qui
      # ont été terminés
      res = self.table_works.select(colonnes: [:abs_work_id], where:where_clause, order:"created_at DESC", limit:20).values
      debug "res : #{res.inspect}"
      debug self.table_works.select.pretty_inspect
      # Parmi ces 20 travaux, je dois garder ceux qui sont de type `task`
      # en sachant que c'est le travail absolu (abs-work) qui consigne cette
      # donnée.
      # Parmi les 20 derniers travaux relevés (il peut n'y en avoir aucun),
      # je dois garder seulement ceux qui sont de type task
      ids_works = Array::new
      res.each do |hwork|
        id_abswork = hwork[:abs_work_id]
        typew = Unan::Program::AbsWork::get( id_abswork ).type_w
        if Unan::Program::AbsWork::CODES_BY_TYPE[:tasks].include?(typew)
          ids_works << hwork[:id]
          break if ids_works.count >= 5
        end
      end
      # Ici, on a nos 5 derniers travaux finis (ou moins, ou rien)
      ids_works.collect do |wid|
        Unan::Program::Work::new(self, wid)
      end
    end
  end

end #/Program
end #/Unan
