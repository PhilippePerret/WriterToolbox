# encoding: UTF-8
=begin

Instance CurPDay pour gérer le pday courant

C'est une classe ESSENTIELLE qui permet de savoir où se trouve
l'auteur.

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

  # {Hash} Utile uniquement pour le CRON pour consigner les
  # avertissements qui sont donnés.
  # Cf. le fichier :
  # ./objet/unan/lib/module/start_pday/program/etat_des_lieux.rb
  attr_accessor :avertissements

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
  def done type = :all      ; done_by_type[type]        end
  # {Array of Hash} TOUS LES TRAVAUX NON TERMINÉS
  def undone type = :all    ; undone_by_type[type]      end
  # {Array of Hash} TOUS LES TRAVAUX DÉMARRÉS NON FINIS
  def started type = :all   ; started_by_type[type]     end
  alias :encours :started
  # {Array of Hash} TOUS LES TRAVAUX RÉCEMMENT FINIS
  # Récent = Fini dans les 10 jours-programme précédents
  def recent type = :all    ; recent_by_type[type]      end
  # {Array of Hash} TOUS LES NOUVEAUX TRAVAUX
  def nouveaux type = :all  ; nouveaux_by_type[type]    end
  # {Array of Hash} TOUS LES TRAVAUX EN DÉPASSEMENT
  def overtimed type = :all ; overtimed_by_type[type]   end
  # {Array of Hash} TOUS LES TRAVAUX POURSUIVIS
  # (donc pas nouveaux et pas en dépassement)
  def poursuivis type = :all ; poursuivis_by_type[type] end
  # {Array of Hash} TRAVAUX NON DÉMARRÉS
  # (attention : ne prend en compte que les travaux du
  #  jour-programme précédent)
  def unstarted type = :all ; unstarted_by_type[type]   end

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
      h = {}
      where = "status < 9 AND created_at < #{NOW} AND program_id = #{program_id}"
      # Note : Le "created_at < NOW" ci-dessus permet de ne
      # pas tenir compte des travaux reprogrammés.
      # Mais pour le moment, on ne peut plus reprogrammer un
      # travail.

      # -> MYSQL UNAN
      uworks = auteur.table_works.select(where: where)
      sbt = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      uworks.each do |wdata|
        wid = wdata[:id]
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

  # Est considéré comme "unstarted" un travail programmé
  # pour la veille au moins et pas encore démarré ou marqué
  # vu pour les pages.
  # Noter que les questionnaires sont exclus pour le moment
  # de cette liste
  def unstarted_by_type
    works_undone(as: :hdata) if @unstarted_by_type == nil
    @unstarted_by_type
  end

  # Méthode de construction de la table des nouveaux
  # travaux
  #
  # Est considéré comme "nouveau" un travail dont le pday est
  # inférieur d'1 au pday courant
  def nouveaux_by_type
    works_undone(as: :hdata) if @nouveaux_by_type == nil
    @nouveaux_by_type
  end

  def overtimed_by_type
    works_undone(as: :hdata) if @overtimed_by_type == nil
    @overtimed_by_type
  end

  def poursuivis_by_type
    works_undone(as: :hdata) if @poursuivis_by_type == nil
    @poursuivis_by_type
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
      where = "status = 9 AND ended_at > #{il_y_a_dix_pdays} AND program_id = #{program_id}"
      # debug "Rythme : #{auteur.program.rythme}"
      # debug "Coefficient durée : #{auteur.program.coefficient_duree}"
      # debug "il_y_a_dix_pdays = #{il_y_a_dix_pdays}::#{il_y_a_dix_pdays.class} (#{il_y_a_dix_pdays.as_human_date(true, true)})"

      # -> MYSQL UNAN
      auteur.table_works.select(where: where).each do |wdata|
        wid = wdata[:id]
        awork_id = wdata[:abs_work_id]
        apday_id = wdata[:abs_pday]
        type_w = wdata[:options][0..1].to_i
        type = Unan::Program::AbsWork::TYPES[type_w][:type]
        rbt[type] << wdata
        rbt[:all] << wdata
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
  # La méthode définit aussi le dépassement du travail.
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
      @nouveaux_by_type = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      @overtimed_by_type = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      @poursuivis_by_type = {
        task:   Array::new,
        page:   Array::new,
        quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      @unstarted_by_type = {
        task:   Array::new,
        page:   Array::new,
        # quiz:   Array::new,
        forum:  Array::new,
        all:    Array::new
      }
      @works_undone_as_hdata ||= begin
        res = {}
        Unan::table_absolute_works.select(where: "id IN (#{ids.join(',')})").collect do |h|
          res.merge! h[:id] => h
        end
        # On ajoute certaines données utiles, dont :
        #   * Le type de travail (:task, :page, :forum ou :quiz)
        #   * Le jour-programme où ce travail était programmé (pour composer
        #   * le `pairid` qui permet de voir si un travail a été démarré pour
        #     ce travail)
        #   * Le nombre de jours de dépassement (if any) ou nil (en jour)
        res.each do |wid, wdata|
          idpday  = @last_pday_of_abswork[wid]
          pairid  = "#{wid}:#{idpday}"
          type    = Unan::Program::AbsWork::TYPES[wdata[:type_w]][:type]
          # Est-ce qu'un travail existe ?
          work_id = if works_started.has_key?(pairid)
            work_id = works_started[pairid][:id]
            work_id
          else
            nil
          end
          is_started = work_id != nil
          # Est-ce un travail du jour. Si c'est le cas, on
          # l'enregistre dans la liste des nouveaux travaux
          is_nouveau = (self.indice - idpday) <= 1
          if is_nouveau
            @nouveaux_by_type[type] << wdata
            @nouveaux_by_type[:all] << wdata
          end
          # Y a-t-il dépassement ?
          reste = wdata[:duree] - (self.indice - idpday)
          if reste >= 0
            depassement = nil
          else
            depassement = - reste # => nombre positif
          end
          is_overtimed = depassement != nil
          # S'il y a dépassement, on enregistre le travail dans
          # les dépassements par type
          if is_overtimed
            @overtimed_by_type[type] << wdata
            @overtimed_by_type[:all] << wdata
          end

          # Un travail qui n'est ni nouveau ni en dépassement
          # est un travail poursuivi
          if !is_nouveau && !is_overtimed
            @poursuivis_by_type[type] << wdata
            @poursuivis_by_type[:all] << wdata
          end

          # Un travail qui n'est ni nouveau ni démarré
          # est un travail unstarted (sauf si c'est un
          # questionnaire)
          if type != :quiz && !is_nouveau && !is_started
            @unstarted_by_type[type] << wdata
            @unstarted_by_type[:all] << wdata
          end
          # Ajout des valeurs
          res[wid].merge!(
            type:         type,
            indice_pday:  idpday,
            work_id:      work_id,
            depassement:  depassement,
            reste:        reste
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
      h = {}
      auteur.table_works.select(where: "status = 9 AND program_id = #{program_id}").each do |wdata|
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

  def program_id
    @program_id ||= auteur.program.id
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
    options[:as] = :ids unless options.key?(:as)
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
      all_pdays_until_now.each do |pddata|
        next if pddata[:works].nil?
        l += pddata[:works].split(' ').collect{|e| "#{e}:#{pddata[:id]}"}
      end
      l
    end
  end

end #/CurPDay
end #/Program
end #/Unan
