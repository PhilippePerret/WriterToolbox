# encoding: UTF-8
=begin
Pour le moment, pour lancer ce module, on utilise en console :

(site.folder_lib_optional+"console/pday_change/main.rb").require
=end
class User

  # = main =
  #
  # Méthode qui change le pday de l'utilisateur pour le mettre
  # au pday +pday_indice+ avec les paramètres optionnels +params+
  # +params+
  #     rythme:  {Fixnum 1 à  9} Le rythme choisi, 5 par défaut
  #    retards:   <nombre> Détermine le nombre de travaux en retard
  #               pour le jour donné. Si TRUE au lieu d'un nombre,
  #               choisi un nombre au hasard.
  def change_pday pday_indice, params = nil
    debug "-> change_pday(pday_indice=#{pday_indice.inspect}, params=#{params.inspect})"
    params ||= Hash::new

    # Initialiser toutes les valeurs de l'user
    # ----------------------------------------
    # Effacer tous les pdays propres enregistrés
    ( table_pdays.delete nil, true )
    # Effacer tous les enregistrements de works
    ( table_works.delete nil, true )
    # Effacer tous les enregistrements de lecture de page
    ( table_pages_cours.delete nil, true )
    # Effacer tous les enregistrements de quiz
    ( table_quiz.delete nil, true )
    # Le total de ses points mis à zéro
    set_var(:total_points => 0)
    set_var(:total_points_program => 0)
    # Toutes les listes des travaux vidées
    ids_lists = {
      works:  Array::new(), # contient tous les travaux
      pages:  Array::new(),
      quiz:   Array::new(),
      tasks:  Array::new(),
      forum:  Array::new(),
      none:   Array::new()  # ?
    }
    ids_lists.each do |id_list, val_list|
      set_var("#{id_list}_ids".to_sym => Array::new)
    end


    # Changer le current_pday de l'user
    set_var(:current_pday, pday_indice)

    # Le rythme adopté par l'user, soit dans les paramètres
    # transmis soit la valeur par défaut.
    params[:rythme] ||= 5
    debug "Rythme : #{params[:rythme]}"

    # Par précaution, on enregistre toujours le rythme du programme
    # dans les données du programme.
    self.set_preference(:rythme => params[:rythme] )

    # Coefficient durée en fonction du rythme
    # DURÉE RÉELLE = DURÉE PROGRAMME x coef_duree
    coef_duree = 5.0 / params[:rythme]

    # On doit régler le jour de commencement du programme pour que
    # ça corresponde au rythme et au jour choisi
    debut_time = NOW - ( coef_duree * ( pday_indice.days - 1000 ) ).to_i
    program.set(created_at: debut_time, updated_at: debut_time + 4000)

    # Remonter les pdays depuis le premier jour jusqu'à la VEILLE
    # du jour voulu pour :
    #   1. Faire les enregistrements de pdays (-> table_pdays)
    #   2. Faire les enregistrements de works (-> table_works)
    (1..pday_indice).each do |pday_id|

      is_current_pday = pday_id == pday_indice

      iabs_pday = ( Unan::Program::AbsPDay::get pday_id )
      iusr_pday = ( Unan::Program::PDay::new program, pday_id )

      # Le temps où a dû être créé le jour-programme (en tenant compte
      # du rythme qui a pu être défini par les paramètres.
      pday_time = (NOW - ( coef_duree * (pday_indice - pday_id + 1).days )).to_i
      debug "NOW        : #{NOW}\n" +
            "pday_time  : #{pday_time}"

      # Le statut du p-day. Il est à 1 quand le PDay est en cours
      # 1: Déclenché par le programme
      # 2: Déclenché par l'user lui-même
      # 4: Achevé
      # Mais ce statut va être décidé en fonction des travaux, suivant le
      # fait qu'il faut laisser des travaux inachevés ou non.
      pday_status = 1
      # pday_status += 2 unless is_current_pday
      pday_status += 4 unless is_current_pday

      # Les points
      # Ces points dépendent des works. Si les paramètres l'exigent
      # certaines travaux peuvent avoir été remis en retard et donc ne
      # pas avoir apportés autant de points que voulus à l'auteur. Dans le cas
      # contraire, on additionne simplement tous les points des travaux.
      # Note : On met aussi à 0 pour le jour courant
      pday_points = 0

      # Si c'est le jour courant, il faut des listes pour
      # mémoriser les travaux à faire :
      if is_current_pday
        ids_lists = {
          works:  Array::new(), # contient tous les travaux
          pages:  Array::new(),
          quiz:   Array::new(),
          tasks:  Array::new(),
          forum:  Array::new(),
          none:   Array::new()  # ?
        }
      end

      # --------------------------------------------------
      # Les travaux
      #
      # Deux traitements différents en fonction du fait que
      # c'est le jour courant ou non. Si ce n'est pas le
      # jour courant, on enregistre ce travail comme s'il
      # avait été fait. Sinon, on l'enregistre dans les
      # travaux à faire.
      # --------------------------------------------------
      iabs_pday.works(:as_instances).each do |iabswork|

        # La durée du travail, approximativement, en fonction
        # du rythme choisi. Pour le moment, on prend le parti
        # que le travail a été exécuté en temps et en heure.
        # Note : Pour le jour courant, bien entendu, le travail
        # n'a pas encore de durée, dont la donnée updated_at est
        # égale à created_at.
        # TODO Tenir compte des paramètres qui peuvent décider qu'on
        # n'est pas ok sur ce travail.
        duree_work = is_current_pday ? 0 : ((iabswork.duree.days * coef_duree) - rand(3600*4)).to_i

        # La date de fin du travail en fonction de sa durée
        work_end_time = pday_time + ( coef_duree * iabswork.duree.days ).to_i

        # Est-ce que c'est un travail fini a priori. Un travail
        # n'est pas fini si sa date de fin `work_end_time` est
        # supérieure à maintenant
        work_is_completed = work_end_time < NOW
        debug "NOW            : #{NOW}\n"+
              "work_end_time  : #{work_end_time}\n"+
              "work_is_completed : #{work_is_completed.inspect}"

        # Pour le moment, le status est mis à 9 pour dire
        # que le travail a été terminé. Plus tard, on pourra modifier
        # cette donnée pour faire des travaux en retard, etc.
        work_status = work_is_completed ? 9 : 0

        # Une instance iwork provisoire, juste pour récupérer
        # les data2save
        iwork_prov = ( Unan::Program::Work::new program, nil )

        # Il faut enregistrer un record work dans la table
        # des works de l'auteur
        data2save = iwork_prov.data2save
        data2save.merge!(
          abs_work_id:  iabswork.id,
          status:       work_status,
          created_at:   pday_time,
          updated_at:   pday_time + duree_work
        )
        work_id = self.table_works.insert( data2save )
        debug "= Création du work ##{work_id} : #{data2save.inspect}"

        # On (RE)prend l'instance du work user, on en aura besoin
        # juste ci-dessous
        iwork = Unan::Program::Work::new( program, work_id )

        # Les points supplémentaires
        # Pour les questionnaires, ce sont les points marqués ou
        # retirés suivant les réponses
        # Note : Cette donnée ne sert pas pour le jour courant
        extra_points = 0

        # Si c'est le jour courant ou que le travail n'est pas
        # terminé, on doit définir les variables
        # de travail de l'user (les vars :tasks, :pages, etc.)
        if is_current_pday || !work_is_completed
          ids_lists[:works]                 << work_id
          ids_lists[iabswork.id_list_type]  << work_id
        else
          # Si ce n'est pas le jour courant, il faut simuler qu'on
          # a fait ce travail.
          #
          # On fonction du type de travail, on peut avoir d'autres
          # enregistrement à faire :
          # - Si c'est une page de cours à lire => un enregistrement dans
          #   la table des pages de cours de l'user avec les lectures
          # - Si c'est un quiz => un enregistrement dans la table des quiz
          #   de l'user avec les résultats (faut-il vraiment le faire ?)
          # - Autre ?
          case iabswork.id_list_type
          when :pages then fakes_lectures_pages( iabswork, iwork)
          when :quiz  then extra_points += fakes_reponses_quiz( iabswork, iwork)
          when :forum then
            # Ne rien faire pour le moment
          else
            # Ne rien faire pour le moment
          end

          # Sans autre forme de procès, on peut ajouter les points
          # de ce travail aux points finaux du pday
          # TODO Pour un questionnaire, il faudrait tenir compte des
          # points marqués.
          # TODO SI les paramètres le demandent, il faut pondérer les
          # points avec quelques retards.
          pday_points += (iabswork.points || 0) + extra_points
        end # / fin de si ce n'est pas un jour programme (dans le `else`)

      end #/loop sur chaque travail du pday courant

      # -----------------------------------------------------
      # Finalisation de la donnée pday pour l'user
      # -----------------------------------------------------

      # On récupère les données pour pouvoir faire les
      # ajustement dans le pday de l'user
      dprov = iusr_pday.data2save

      # Il faut calculer le temps auquel aurait été créé
      # ce jour-programme (notamment pour le modifier dans la
      # donnée enregistrée)
      dprov.merge!(
        id:           iabs_pday.id,
        program_id:   program_id,
        status:       pday_status,
        points:       pday_points,
        updated_at:   pday_time,
        created_at:   pday_time
      )
      iusr_pday.instance_variable_set('@data2save', dprov)
      debug "* Création du pday ##{iusr_pday.id} : #{iusr_pday.data2save.inspect}"
      iusr_pday.create

      # On ajoute les points à l'auteur courant
      self.add_points pday_points unless is_current_pday

      # Si c'est le jour courant, on doit enregistrer les
      # travaux dans les variables de l'auteur
      if is_current_pday
        ids_lists.each do |key_list, arr_works|
          next if arr_works.empty?
          key = "#{key_list}_ids".to_sym.freeze
          list = self.get_var(key, Array::new)
          list += arr_works
          self.set_var( key, list)
        end
      end

    end

  end


  # Simuler des lectures de pages, c'est-à-dire créer un enregistrement
  # de lecture de page dans la table de l'user courant.
  def fakes_lectures_pages iabswork, iwork
    create_time = iwork.created_at + rand(4*3600)
    # Faire des lectures, de 1 à 4
    lectures = Hash::new
    current_lecture_time = "#{create_time}".to_i
    ( 1 + rand(4) ).times.each do |itime|
      current_lecture_time += 120 + rand(3600)
      lectures.merge!( current_lecture_time => current_lecture_time )
    end

    # Le hash de données final
    data2save = {
      id:           iabswork.item_id, # Identifiant de la page de cours à lire
      status:       9, # Pourra être modifiés suivant les paramètres
      lectures:     lectures,
      created_at:   create_time,
      updated_at:   iwork.updated_at - 100
    }

    # Enregistrement du record pour la page de cours à lire
    self.table_pages_cours.insert( data2save )

  end

  # Simuler le remplissage d'un questionnaire au cours d'un travail, c'est-à-dire
  # donner des réponses
  # RETOURNE le nombre de points marqués, ABSOLUMENT
  def fakes_reponses_quiz iabswork, iwork

    create_time       = iwork.created_at + rand(24*3600)
    total_points_user = 0

    iabsquiz = Unan::Quiz::new( iabswork.item_id )

    hash_reponses = Hash::new
    iabsquiz.questions.each do |iquestion|
      reps = iquestion.reponses
      nombre_reponses = reps.count
      indice_hasard   = rand(nombre_reponses)
      reponse_points  = reps[indice_hasard][:points]
      total_points_user += reponse_points
      hash_reponses.merge!(
        iquestion.id => {
          qid:        iquestion.id,
          max:        iquestion.max_points,
          points:     reponse_points,
          value:      (indice_hasard + 1)
        }
      )
    end

    data2save = {
      quiz_id:      iabswork.item_id,
      type:         iabswork.type,
      points:       total_points_user,
      max_points:   iabsquiz.max_points,
      reponses:     hash_reponses.to_json,
      created_at:   create_time
    }

    self.table_quiz.insert( data2save )

    return total_points_user

  end
end
