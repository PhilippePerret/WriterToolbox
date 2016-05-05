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

  # ---------------------------------------------------------------------
  # Méthodes retournant des listes de travaux suivant
  # leur type et leur état (achevés, démarrés, etc.)
  # ---------------------------------------------------------------------

  # {Array of Hash} TOUS LES TRAVAUX TERMINÉS
  def done type = :all; done_by_type[type] end

  # {Array of Hash} TOUS LES TRAVAUX NON TERMINÉS
  def undone type = :all; undone_by_type[type] end

  # {Array of Hash} TOUS LES TRAVAUX DÉMARRÉS NON FINIS
  def started type; started_by_type[type]  end
  alias :encours :started
  # def encours type; encours_by_type[type] end

  # {Array of Hash} TOUS LES TRAVAUX RÉCEMMENT FINIS
  # Récent = Fini dans les 10 jours-programme précédents
  def recent type = :all; recent_by_type[type] end

  # ---------------------------------------------------------------------
  #   Méthodes de nombre
  # ---------------------------------------------------------------------

  # Nombre des travaux non terminés
  def nombre_travaux_courant ; @nb_w_courant ||= undone(:all).count end


  # ---------------------------------------------------------------------
  # Méthodes de construction des tables
  # qui permet d'utiliser les méthodes ci-dessus.
  # ---------------------------------------------------------------------

  # Méthode de construction de la table des travaux
  # achevés par type.
  #
  # Utile pour la méthode `done(type)`
  def done_by_type type
    @done_of_type ||= begin
      h = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      works_done(as: :hdata).each do |wid, wdata|
        h[wdata[:type]] << wdata
        h[:all]         << wdata
      end
      h
    end
  end

  # Méthode qui construit la table des travaux non
  # achevés en les classant par type
  #
  # Utile pour la méthode `undone`
  def undone_by_type
    @undone_by_type ||= begin
      h = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      works_undone(as: :hdata).each do |wid, wdata|
        h[wdata[:type]] << wdata
        h[:all] << wdata
      end
      h
    end
  end

  # Méthode de construction de la table des travaux
  # commencés (c'est-à-dire qui possède une instance work pour
  # l'auteur)
  def started_by_type
    @started_by_type ||= begin
      h = Hash::new
      uworks = auteur.table_works.select(where: "status < 9")
      sbt = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      uworks.each do |wid, wdata|
        type_w = wdata[:options][0..1].to_i
        wdata.merge!(
          type_w:     type_w,
          type:       Unan::Program::AbsWork::TYPES[type_w][:type]
          )
        sbt[wdata[:type]] << wdata
        sbt[:all]         << wdata
        h.merge!( "#{wdata[:abs_work_id]}:#{wdata[:abs_pday]}" => wdata )
      end
      @works_started = h
      sbt
    end
  end

  # Méthode de construction de la table des travaux récents
  # Un travail récent est un travail qui a été terminé dans
  # les 7 jours-programme mais on ne met que :
  #   - tous les travaux des 3 derniers jours
  #   - On ajoute les autres jusqu'à 10 travaux par type
  #
  # Note : contrairement aux autres listes, ces listes là sont
  # classées par date (par jour-programme).
  def recent_by_type
    @recent_by_type ||= begin
      rbt = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      # On commence par récupérer tous les travaux finis qui datent
      # de moins de 10 jours (précisément : ceux qui ont été FINIS dans
      # les dix jours précédents)
      # On relève le hash des données travail.
      il_y_a_dix_pdays = (NOW - (10.days * auteur.program.coefficient_duree)).to_i
      where = "status = 9 AND ended_at > #{il_y_a_dix_pdays}"
      # debug "Rythme : #{auteur.program.rythme}"
      # debug "Coefficient durée : #{auteur.program.coefficient_duree}"
      # debug "il_y_a_dix_pdays = #{il_y_a_dix_pdays}::#{il_y_a_dix_pdays.class} (#{il_y_a_dix_pdays.as_human_date(true, true)})"
      auteur.table_works.select(where: where).each do |wid, wdata|
        awork_id = wdata[:abs_work_id]
        apday_id = wdata[:abs_pday]
        type_w = wdata[:options][0..1].to_i
        type = Unan::Program::AbsWork::TYPES[type_w][:type]
        rbt[type] << wdata
      end

      # On trie chaque liste de type par date, les plus récents
      # en premier
      #
      # Note : Ça n'est pas ici qu'on réduit la liste à ses seuls
      # 10 premiers éléments. Il faudra le faire au besoin.
      rbt.each do |type, liste|
        rbt[type] = liste.sort_by{|h| - h[:ended_at]}
      end
      debug "table des travaux récents : #{rbt.pretty_inspect}"
      # On rend finalement la liste
      rbt
    end
  end

  # ---------------------------------------------------------------------
  #   /Fin des méthodes de construction des tables des travaux
  # ---------------------------------------------------------------------

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

  # Nombre de travaux à démarrer par +type+
  def nombre_tostart_of_type type
    undone(type).count - started(type).count
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
    @works_started || started_by_type

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


  # ---------------------------------------------------------------------
  # Méthodes de collecte des travaux
  # ---------------------------------------------------------------------
  #
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

  # Liste des IDs de tous les travaux jusqu'au jour-programme
  # courant.
  #
  # Noter qu'il peut y en avoir des milliers si nous
  # sommes dans les derniers jours.
  #
  # Cette méthode alimente la méthode `works_until_now`
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
