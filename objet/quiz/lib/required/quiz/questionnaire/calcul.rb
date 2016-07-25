# encoding: UTF-8
class Quiz

  # = main =
  #
  # Méthode principale appelée lorsque l'on clique sur le bouton
  # pour soumettre le quiz
  #
  # Si la questionnaire a bien été enregistré, elle construit le
  # rapport à afficher, avec le résultat et les réponses corrigées.
  #
  # Si c'est un user inscrit (abonné, unanunscript, etc.), on
  # enregistre son quiz dans la table des résultats.
  #
  def evaluate
    # Avant d'établir le rapport on met de côté les data générales
    # qui peuvent être enregistrées afin de pouvoir mieux commenter la
    # note obtenue par l'utilisateur
    get_data_generales

    if ureponses.nil?
      @error = :aucune_reponse
      @report = 'Voyons ! Il faut remplir le quiz, pour obtenir une évaluation !'
      @do_evaluation = false
    elsif pas_toutes_les_reponses?
      @error = :nombre_reponses_insuffisant
      @report = 'Il faut répondre à toutes les questions, pour obtenir une évaluation intéressante.'
      @do_evaluation                  = false
      @do_exergue_reponses_manquantes = true
    else
      # On calcule le rapport
      @do_evaluation = true
      report
      # Enregistrement du résultat :
      #   - dans la table des résultats pour l'user s'il est identifié
      #   - toujours dans la table général :cold, quiz qui consigne toutes
      #     les notes et toutes les soumissions.
      save_resultat
    end
  end

  # Note maximale et minimale obtenue à ce test (pour commenter
  # la note obtenue par l'user)
  attr_reader :current_note_max, :current_note_min
  def get_data_generales
    return nil if data_generales.nil?
    @current_note_max = data_generales[:note_max]
    @current_note_min = data_generales[:note_min]
  end


  # Pour savoir s'il faut faire une évaluation ou simplement
  # remettre les réponses qui avaient été données.
  # Cela est nécessaire par exemple lorsque l'user en donne pas
  # toutes les réponses.
  def evaluation?
    @do_evaluation = false if @do_evaluation === nil
    @do_evaluation
  end

  def exergue_reponses_manquantes?
    @do_exergue_reponses_manquantes = false if @do_exergue_reponses_manquantes === nil
    @do_exergue_reponses_manquantes
  end

  # Retourne TRUE si toutes les réponses n'ont pas été
  # données
  def pas_toutes_les_reponses?
    questions_ids.count != ureponses.count
  end

  # Retourne la note finale sur 20
  def unote_finale
    @unote_finale ||= begin
      r = ((unombre_points.to_f / nombre_points_total) * 20).round(1)
      r.to_i != r || r = r.to_i
      r
    end
  end

  # Retourne le nombre de points marqués par l'user pour
  # ce quiz.
  #
  # La première fois, la méthode calcule aussi le nombre de
  # points maximum pour ce quiz
  #
  def unombre_points
    @unombre_points ||= begin
      upoints = 0
      mpoints = 0
      ureponses.each do |qid, dreponse|
        upoints += dreponse[:upoints]
        mpoints += dreponse[:points]
      end
      @nombre_points_total = mpoints
      upoints
    end
  end

  def nombre_points_total
    @nombre_points_total != nil || unombre_points
    @nombre_points_total
  end

  # = main =
  #
  # Les réponses de l'user
  # C'est un Hash qui contient en clé l'ID de la question et en valeur
  # un Hash contenant :
  #   :qid            ID de la question
  #   :type           :radio ou :checkbox
  #   :rep_index      L'index de la réponse pour un radio
  #                   Les index des réponses pour un checkbox
  #   Seront définis plus tard :
  #     :better_reps  Index de valeurs positives
  #     :best_rep     Index de la meilleure valeur si plusieurs
  #                   Ou liste des index si plusieurs meilleures
  #     :points       Nombre total de points pour cette question
  #     :upoints      Nombre de points marqués par l'user pour cette
  #                   question
  #     :is_correct   Est mis à true si l'utilisateur a choisi la bonne
  #                   réponse.
  #
  def ureponses
    @ureponses ||= begin
      if param(prefix_reponse).nil?
        nil
      else
        # On récupère les réponses de l'user
        ureps = get_indexes_reponses
        # On renseigne le hash des valeurs de chaque réponse
        # comparées aussi aux réponses de l'utilisateur
        calcule_points(ureps)
      end
    end
  end

  # = main =
  #
  # Calcule des points
  #
  # Retourne le Hash des réponses de l'user auquel a été
  # ajouté toutes les infos sur les réponses attendues et les
  # points marqués.
  #
  # Cette valeur sera affectée à la propriété `ureponses` de
  # l'instance du quiz courante.
  #
  # +ureps+ est le Hash préparé par la méthode `get_indexes_reponses`
  # qui a relevé les réponses de l'user en mettant en clé l'id de
  # la question et en valeur un hash contenant différentes valeurs
  # (cf. ureponses qui les décrit)
  #
  def calcule_points ureps
    ureps.each do |qid, urep|
      question = hquestions[qid]

      # Réponse(s) de l'utilisateur
      # Si c'est un checkbox, c'est une liste des indexes
      # choisis, si c'est un radio, c'est seulement la valeur
      # de l'index de la réponse choisie (qui est forcément définie)
      index_reponse = urep[:rep_index]

      is_checkbox = urep[:type] == :checkbox
      is_radio    = urep[:type] == :radio

      # Le nombre de points marqués par l'user
      urep[:upoints] =
        case index_reponse
        when Array  # checkboxes
          index_reponse.collect{|irep| question.hreponses[irep][:pts].to_i }.inject(:+)
        when Fixnum # radio
          question.hreponses[index_reponse][:pts].to_i
        end
      # debug "Question : #{question.question}"
      # debug "index_reponse : #{index_reponse.inspect}"
      # debug "urep[:upoints] = #{urep[:upoints].inspect}"


      # Les meilleures réponses
      #
      # On prend toute réponse qui est supérieure à 0,
      # mais en mettant de côté la meilleure réponse d'entre
      # toutes.
      #
      # Pour un checkbox, le nombre de points pour la question
      # correspond à la somme de tous les points.
      # Pour un radio, le nombre de points pour la question
      # correspond au nombre de points maximaum
      #
      urep[:better_reps]  = Array.new
      urep[:points]       = 0
      question.hreponses.each_with_index do |hrep, irep|
        pts = hrep[:pts].to_i
        # On ajoute l'index de réponse à la liste des
        # meilleures réponses si le nombre de points est
        # positif
        urep[:better_reps] << irep if pts > 0

        if is_checkbox
          # Pour des checkbox, le nombre de points de la question
          # correspond à la somme de toutes les valeurs (0 ou non)
          urep[:points] += pts
        else
          # Pour des boutons radio, dont plusieurs peuvent avoir une
          # valeur positive (dégradé de valeur de réponse), on prend
          # la valeur maximum.
          #
          # On met cette réponse en meilleure réponse si c'est
          # elle qui a le plus de points et que c'est une
          # question radio
          # Attention : la valeur peut être surclassée par les
          # réponses suivantes, donc ça n'est certainement pas
          # ici qu'il faut voir si c'est la réponse correcte
          # pour l'user.
          if pts > urep[:points]
            urep[:good_rep] = irep
            urep[:points]   = pts
          end
        end
      end

      # S'il n'y a qu'une seule bonne réponse, on la met
      # dans :good_rep si on se trouve avec un bouton
      # radio
      if urep[:type] == :radio && urep[:better_reps].count == 1
        urep[:good_rep] = urep[:better_reps].first
      end

      # On peut déterminer si la réponse est bonne ou non
      # Elle est simplement bonne si le nombre de points est
      # équivalent au nombre de points pour la question.
      urep[:is_correct] = urep[:points] == urep[:upoints]


      # On remet le hash de la question entièrement renseignée
      ureps[qid] = urep
    end
    return ureps
  end

  # Pour la préparation du Hash `ureponses` contenant toutes
  # les réponses de l'user. Cette méthode met dans un hash
  # les réponses choisies par l'user.
  #
  # C'est la première préparation du hash de réponses
  #
  def get_indexes_reponses
    ureps = Hash.new
    param(prefix_reponse).each do |kquestion, valeur|
      hrep = {
        qid:            nil,  # ID de la question
        type:           nil,  # Le type, :radio ou :checkbox
        is_good:        nil,  # True si la réponse est correcte
        is_correct:     nil,  # true: bonne réponse, false: mauvaise réponse
                              # choisie par l'user, nil: mauvaise réponse
        rep_index:      nil,  # Index (ou liste) de la réponse choisie
        good_rep:       nil,  # La bonne valeur (if any)
        best_reps:      nil,  # Les meilleures valeurs (if plusieurs)
        points:         nil,  # Le nombre de points maximum
        upoints:        nil   # Le nombre de points de l'user
      }

      # On récupère la partie contenant l'ID de la question.
      # Attention, c'est "12" pour un radio, mais "12_2" pour
      # un checkbox
      q_id = kquestion[3..-1]


      if q_id.match(/_/) # => checkbox
        hrep[:type] = :checkbox
        # Traitement d'un checkbox. Il peut déjà exister un
        # champ hrep
        q_id, index_reponse = q_id.split('_').collect{|e| e.to_i}

        # On prend l'enregistrement s'il existe déjà ou on
        # prend un vierge pour le créer si c'est la première
        # fois qu'il y a une case cochée à cette question
        hrep =
          if ureps.key?(q_id)
            ureps[q_id]
          else
            hrep[:rep_index] = Array.new
            hrep
          end
        # On ajoute cette case à cocher
        hrep[:rep_index] << index_reponse.to_i
      else # => radio
        q_id = q_id.to_i
        hrep[:type]       = :radio
        hrep[:rep_index]  = valeur.to_i
      end

      # On ajoute les valeurs calculées
      hrep.merge!(
        qid: q_id
      )
      ureps.merge!(q_id => hrep)
    end
    return ureps
  end


end
