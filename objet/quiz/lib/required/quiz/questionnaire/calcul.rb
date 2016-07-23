# encoding: UTF-8
class Quiz

  # = main =
  #
  # Méthode principale appelée lorsque l'on clique sur le bouton
  # pour soumettre le quiz
  def evaluate
    if ureponses.nil?
      @error = :aucune_reponse
      @report = 'Voyons ! Il faut remplir le quiz, pour obtenir une évaluation !'
    elsif pas_toutes_les_reponses?
      @error = :nombre_reponses_insuffisant
      @report = 'Il faut répondre à toutes les questions, pour obtenir une évaluation intéressante.'
      @do_evaluation                  = false
      @do_exergue_reponses_manquantes = true
    else
      # On calcule le rapport
      @do_evaluation = true
      report
    end
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
  #   :rep_index      L'index de la réponse pour un radio
  #                   Les index des réponses pour un checkbox
  #   Seront définis plus tard :
  #     :good_value   Index de la bonne valeur si une seule
  #     :best_value   Index de la meilleure valeur si plusieurs
  #                   Ou liste des index si plusieurs meilleures
  #     :points       Nombre de points pour cette question
  #     :upoints      Nombre de points marqués par l'user pour cette
  #                   question
  #
  def ureponses
    @ureponses ||= begin
      if param(prefix_reponse).nil?
        nil
      else
        # On récupère les réponses de l'user
        ureps = get_indexes_reponses
        # On met dans le hash les valeurs de chaque réponse
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
      index_reponse = urep[:rep_index]
      # Le nombre de points marqués par l'user
      urep[:upoints] =
        case index_reponse
        when Array  # checkboxes
          sum = 0
          index_reponse.each do |irep|
            sum += question.hreponses[irep][:pts].to_i
          end
          sum
        when Fixnum # radio
          question.hreponses[index_reponse][:pts].to_i
        end
      # Les meilleures réponses
      points_max  = 0
      better_reps = Array.new
      question.hreponses.each_with_index do |hrep, irep|
        if hrep[:pts].to_i > points_max
          better_reps = [irep]
          points_max  = hrep[:pts].to_i
        elsif hrep[:pts].to_i == points_max
          better_reps << irep
        end
      end

      # On affecte les valeurs des meilleures réponses
      if better_reps.count == 1
        urep[:good_rep]   = better_reps.first
        urep[:points]     = points_max
      else
        urep[:best_reps]  = better_reps
        urep[:points]     = 0
        better_reps.each do |irep|
          urep[:points] += question.hreponses[irep][:pts].to_i
        end
      end

      # On peut déterminer si la réponse est bonne ou non
      # Elle est simplement bonne si le nombre de points est
      # équivalent au nombre de points pour la question.
      urep[:is_good] = urep[:points] == urep[:upoints]

      # La meilleure réponse (s'il n'y a qu'une seule meilleure
      # réponse)

      # On remet le hash de la question corrigé
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
        is_good:        nil,  # True si la réponse est correcte
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
        hrep[:rep_index] = valeur.to_i
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
