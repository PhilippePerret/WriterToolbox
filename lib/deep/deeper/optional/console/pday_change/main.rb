# encoding: UTF-8
=begin
Pour le moment, pour lancer ce module, on utilise en console :

(site.folder_lib_optional+"console/pday_change/main.rb").require
=end
class User


  def sub_log mess
    if defined?(Console)
      console.sub_log( mess )
    else
      debug mess
    end
  end

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
    # debug "-> change_pday(pday_indice=#{pday_indice.inspect}, params=#{params.inspect})"
    params ||= {}

    # Réglage et analyse des options
    # Le rythme adopté par l'user, soit dans les paramètres
    # transmis soit la valeur par défaut.
    params[:rythme] ||= 5
    # debug "Rythme : #{params[:rythme]}"
    # Faut-il régler l'heure juste avant ou juste après le changement
    # de jour
    just_in_time = !!params.delete(:just_in_time)

    # Changer le current_pday du programme de l'user
    program.current_pday= pday_indice

    # Par précaution, on enregistre toujours le rythme du programme
    # dans les données du programme.
    self.set_preference(:rythme => params[:rythme] )

    # Coefficient durée en fonction du rythme
    # DURÉE RÉELLE = DURÉE PROGRAMME x coef_duree
    coef_duree = 5.0 / params[:rythme]

    # Pour pouvoir se trouver à la 23e heure du jour voulu (afin que
    # les travaux à faire ou à finir dans la journée ne soient pas
    # marqués en retard)
    faux_now = "#{NOW}".to_i
    faux_now += just_in_time ? -100 : 3600

    # On doit régler le jour de commencement du programme pour que
    # ça corresponde au rythme et au jour choisi
    debut_time = faux_now - ( coef_duree * ( pday_indice.days - 1000 ) ).to_i
    program.set(created_at: debut_time, updated_at: debut_time + 4000)

    unless just_in_time
      sub_log "Noter que le temps choisi est <strong>une heure avant la fin du #{pday_indice}<sup>e</sup> jour</strong>. Donc les travaux de la veille doivent être encore activés."
    else
      sub_log "Noter qu'avec l'option “just_in_time”, les travaux qui doivent être terminés le #{pday_indice}<sup>e</sup> jour seront marqués en dépassement de temps."
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
