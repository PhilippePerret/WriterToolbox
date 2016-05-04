# encoding: UTF-8
=begin

Instance CurPDay pour gérer le pday courant

Ce module doit pouvoir être chargé en standalone, par exemple
par le traitement de la pastille qui indique à l'auteur
les taches qu'il a à faire, etc.

Une fois chargé par :

  SuperFile::new('./objet/unan/lib/required/cur_pday').require

On peut l'instancier avec :

  icurday = Unan::Program::CurPDay::new( <{Fixnum} indice pday>, <{User} auteur> )

=end
require './objet/unan/lib/required/user/database.rb'

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
    @auteur = User::get(@auteur) if @auteur.instance_of?(Fixnum)
  end


  def nombre_travaux_courant
    @nombre_travaux_courant ||= begin
      works_undone.count
    end
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

  # Retourne les listes {Array} contenant des
  # hash de données de travaux EXÉCUTÉS
  def done_tasks  ; @done_tasks ||= done_of_type(:task)   end
  def done_pages  ; @done_pages ||= done_of_type(:page)   end
  def done_quiz   ; @done_quiz  ||= done_of_type(:quiz)   end
  def done_forum  ; @done_forum ||= done_of_type(:forum)  end
  # Retourne la liste {Array} des Hash de données
  # des travaux DÉMARRÉS de type +type+
  def done_of_type type
    @done_of_type ||= begin
      h = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new
      }
      works_done(as: :hdata).each do |wid, wdata|
        h[wdata[:type]] << wdata
      end
      h
    end
    @done_of_type[type]
  end

  # Les tâches en cours, par type
  def tasks_encours   ; @tasks_encours  ||= encours_of_type(:task)  end
  def pages_encours   ; @pages_encours  ||= encours_of_type(:page)  end
  def quiz_encours    ; @quiz_encours   ||= encours_of_type(:quiz)  end
  def forum_encours   ; @forum_encours  ||= encours_of_type(:forum) end
  def encours_of_type type
    @encours_of_type ||= begin
      h = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new
      }
      works_started(as: :hdata).each do |wid, wdata|
        h[wdata[:type]] << wdata
      end
      h
    end
    @encours_of_type[type]
  end

  # Retourne des listes {Array} contenant des
  # Hash des données de travaux NON DÉMARRÉS
  # par l'auteur
  def undone_tasks  ; @undone_tasks ||= undone_of_type(:task)   end
  def undone_pages  ; @undone_pages ||= undone_of_type(:page)   end
  def undone_quiz   ; @undone_quiz  ||= undone_of_type(:quiz)   end
  def undone_forum  ; @undone_forum ||= undone_of_type(:forum)  end
  # Retourne la liste {Array} des Hash de données
  # des travaux NON TERMINÉS de type +type+
  def undone_of_type type
    @undone_by_type ||= begin
      h = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new
      }
      works_undone(as: :hdata).each do |wid, wdata|
        h[wdata[:type]] << wdata
      end
      h
    end
    @undone_by_type[type]
  end

  # Retourne la liste des travaux non accomplis par l'auteur
  # courant au jour-programme courant
  #
  # Note : Si c'est un travail qui a été commencé, le hash
  # de données retourné (if any) définit également `work_id`
  # l'identifiant du travail dont il est question.
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

    case options[:as]
    when :hdata
      return @works_undone_as_hdata unless @works_undone_as_hdata.nil?
    when :ids
      return @works_undone_as_ids unless @works_undone_as_ids.nil?
    end

    @non_accomplis ||= begin
      undone = works_until_now(as: :hash_ids).dup
      works_done.each do |idpaire, vrai|
        undone.delete(idpaire)
      end
      undone
    end

    # Première opération : pour certains :as, on doit
    # déjà récupérer l'identifiant seul (entendu que la
    # "paire" est constituée pour le moment de l'identifiant,
    # d'un double-point et de l'indice du jour-programme)
    case options[:as]
    when :ids, :hdata
      @last_pday_of_abswork = Hash::new
      ids = @non_accomplis.collect do |idpaire, vrai|
        wid, indice_pday = idpaire.split(':')
        wid = wid.to_i
        # Associer le pday au wid. Noter que ce sera toujours
        # seulement le dernier pday qui sera associé, même
        # lorsque l'abs_work est utilisé plusieurs fois
        @last_pday_of_abswork.merge!( wid => indice_pday.to_i )
        # Retourner l'identifiant du work
        wid
      end
    end

    # Le retour renvoyé en fonction du :as
    case options[:as]
    when :ids
      @works_undone_as_ids ||= ids
    when :hdata
      @works_undone_as_hdata ||= begin
        res = Unan::table_absolute_works.select(where: "id IN (#{ids.join(',')})")
        # On ajoute certaines données utiles, dont :
        #   Le type de travail (:task, :page, :forum ou :quiz)
        #   Le jour-programme où ce travail était programmé (pour composer
        #   le `pairid` qui permet de voir si un travail a été démarré pour
        #   ce travail)
        res.each do |wid, wdata|
          idpday = @last_pday_of_abswork[wid]
          pairid = "#{wid}:#{idpday}"
          # Est-ce qu'un travail existe ?
          work_id = if works_started.has_key?(pairid)
            work_id = works_started[pairid][:id]
            work_id
          else
            nil
          end
          res[wid].merge!(
            type:         Unan::Program::AbsWork::TYPES[wdata[:type_w]][:type],
            indice_pday:  idpday,
            work_id:      work_id
            )
        end
        res
      end
    end
  end

  # Retourne un Hash des travaux en cours qui ont été
  # démarrés mais pas encore finis. Ça correspond aux
  # travaux vraiment en cours
  #
  # Noter qu'avec l'option :hdata, il y a en clé ce
  # que j'appelle le `pairid` du travail c'est-à-dire un
  # identifiant composé de "<abs work id>:<pday du travail>"
  # pour pouvoir le retrouver exactement quand il y a plusieurs
  # fois le même abs-work qui est utilisé plusieurs jours
  # différents.
  def works_started options = nil
    @works_started ||= begin
      h = Hash::new
      uworks = auteur.table_works.select(where: "status < 9")
      uworks.each do |wid, wdata|
        type_w = wdata[:options][0..1].to_i
        wdata.merge!(
          type_w: type_w,
          type:   Unan::Program::AbsWork::TYPES[type_w][:type]
          )
        h.merge!( "#{wdata[:abs_work_id]}:#{wdata[:abs_pday]}" => wdata )
      end
      h
    end

    options ||= Hash::new
    options[:as] = :hdata unless options.has_key?(:as)

    case options[:as]
    when :hdata then @works_started
    end
  end
  # Retourne un {Hash} avec en clé une clé composée par :
  #   '<abswork id>:<abspday>'
  # et en valeur true
  #
  def works_done options = nil
    @works_done ||= begin
      h = Hash::new
      uworks = auteur.table_works.select(where: "status = 9")
      uworks.each do |wid, wdata|
        h.merge!( "#{wdata[:abs_work_id]}:#{wdata[:abs_pday]}" => wdata )
      end
      h
    end

    options ||= Hash::new
    options[:as] = :hdata unless options.has_key?(:as)

    case options[:as]
    when :hdata then @works_done
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
