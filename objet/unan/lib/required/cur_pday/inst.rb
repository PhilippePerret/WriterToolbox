# encoding: UTF-8
=begin

Instance CurPDay pour gérer le pday courant

=end
class Unan
class Program
class CurPDay

  # {Fixnum} Jour-programme courant (son indice, par exemple
  # 1 pour le premier jour-programme du programme)
  attr_reader :indice

  # {User} Auteur de ce jour-programme. Par défaut, ou plutôt
  # en règle générale, il s'agit du visiteur, mais on met cette
  # possibilité pour pouvoir utiliser ces méthodes en tant
  # qu'administrateur
  attr_reader :auteur

  # +indice+ {Fixnum} Le numéro du jour-programme
  # courant.
  # +auteur+ {User} Auteur de ce jour-programme courant
  def initialize indice, auteur = nil
    @indice = indice
    @auteur = auteur || user
  end

  # Retourne absolument tous les travaux qui sont à faire
  # jusqu'au jour-programme courant, ce jour compris
  #
  # +options+
  #   :as détermine la nature des éléments de la liste
  #   retournée :
  #     :ids            Liste d'IDs des abs_works avec leur abs_pday
  #                     "<abs work id>:<abs pday>"
  #     :instances      Liste d'instance Unan::Program::AbsWork
  #     :hash_instances Hash d'instance avec en clé leur identifiant
  def works_until_now options = nil
    options ||= Hash::new
    options[:as] = :ids unless options.has_key?(:as)
    case options[:as]
    when :ids then all_works_ids_until_now
    when :hash_ids then
      h = Hash::new
      all_works_ids_until_now.each { |paire| h.merge!(paire => true) }
      h
    when :instances
      all_works_ids_until_now.collect{|widpd| awid, pd = widpd.split(':'); Unan::Program::AbsWork::get(awid)}
    when :hash_instances
      h = Hash::new
      all_works_ids_until_now.each do |widpd|
        awid, pd = widpd.split(':')
        h.merge! awid => Unan::Program::AbsWork::get(awid)
      end
      h
    end
  end

  # Retourne la liste des travaux non accomplis par l'auteur
  # courant au jour-programme courant
  #
  # :options:
  #   :as   Détermine le format du retour
  #       :ids    Simple liste des identifiants d'abs_work
  #       :hdata  Hash avec en clé l'identifiant du abs_work et
  #               en valeur ses données + quelques autres données
  #               ajoutées telles que :
  #                   type: :task, :quiz, :forum ou :page
  #               (FORMAT PAR DEFAUT)
  def works_undone options = nil
    options ||= Hash::new
    options[:as] = :hdata unless options.has_key?(:as)

    non_accomplis = works_until_now(as: :hash_ids).dup
    debug "non_accomplis au départ : #{non_accomplis.inspect}"
    debug "works_done : #{works_done.inspect}"
    works_done.each do |idpaire, vrai|
      non_accomplis.delete(idpaire)
    end
    "non_accomplis à la fin : #{non_accomplis.inspect}"
    non_accomplis

    # Première opération : pour certains :as, on doit
    # déjà récupérer l'identifiant seul (entendu que la
    # "paire" est constituée pour le moment de l'identifiant,
    # d'un double-point et de l'indice du jour-programme)
    ids = case options[:as]
    when :ids, :hdata
      non_accomplis.collect {|idpaire, vrai| idpaire.split(':').first.to_i }
    end

    case options[:as]
    when :ids then ids
    when :hdata
      res = Unan::table_absolute_works.select(where: "id IN (#{ids.join(',')})")
      # On ajoute certaines données utiles
      res.each do |wid, wdata|
        res[wid].merge!(
          type: Unan::Program::AbsWork::TYPES[wdata[:type_w]][:type]
          )
      end
      res
    end
  end

  # Retourne un {Hash} avec en clé une clé composée par :
  #   '<abswork id>:<abspday>'
  # et en valeur true
  #
  def works_done
    @works_done ||= begin
      h = Hash::new
      uworks = user.table_works.select(where: "status = 9", colonnes:[:abs_work_id, :abs_pday, :status])
      uworks.each do |wid, wdata|
        h.merge!( "#{wdata[:abs_work_id]}:#{wdata[:abs_pday]}" => true )
      end
      h
    end
  end
  # On relève tous les travaux qui ont été à faire
  # jusqu'au jour-programme courant.
  # Noter qu'il peut y en avoir des milliers si nous
  # sommes dans les derniers jours.
  #
  # Note : Utiliser plutôt la méthode `works_until_now(as: :ids)`
  # pour obtenir cette liste (pourquoi ? Je ne sais pas, peut-être
  # pour ne pas l'oublier)
  def all_works_ids_until_now
    @all_works_ids_until_now ||= begin
      all_pdays_until_now = Unan::table_absolute_pdays.select(where:"id <= #{indice}", colonnes:[:works])
      l = Array::new
      all_pdays_until_now.each do |pdid, pddata|
        next if pddata[:works].nil?
        l += pddata[:works].split(' ').collect{|e| "#{e}:#{pdid}"}
      end
      l
    end
  end

end #/CurPDay
end #/Program
end #/Unan
