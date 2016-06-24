# encoding: UTF-8
=begin

Module de calcul d'un questionnaire

=end
require 'json'

class Unan
class Quiz

  attr_reader :awork_id
  attr_reader :awork_pday

  # = main =
  #
  # Méthode principale appelée dès que l'auteur soumet son
  # questionnaire.
  #
  # Il peut avoir renseigné le questionnaire ou ne pas
  # l'avoir renseigné.
  #
  # Cette méthode :
  #   - évalue le questionnaire
  #   SI NOT OK
  #     En cas de problème, il ré-affiche le questionnaire
  #   SI OK
  #     - Elle enregistre le résultat dans la table des quiz
  #       de l'auteur.
  #     - Elle affiche un message de résultat en fonction des
  #       réponses.
  #
  # +args+
  #   awork_id:     ID du travail absolu pour cette évaluation
  #
  def evaluate_and_save args

    # On en aura besoin pour la sauvegarde du résultat
    @awork_id   = args[:awork_id]
    @awork_pday = args[:awork_pday]

    # Evaluation du questionnaire
    #
    # is_conforme est false si le questionnaire n'a pas
    # été rempli complètement. Dans ce cas, on le réaffiche
    # en remettant les réponses déjà données.
    is_conforme = evalute_quiz
    return false unless is_conforme

    # Si ce n'est pas un questionnaire multi (utilisable plusieurs
    # fois) et qu'il est déjà enregistré, il faut envoyer une
    # alerte et s'en retourner.
    if !multi? && auteur_has_this_quiz?
      return error "Votre questionnaire a déjà été enregistré.<br />Merci de ne pas le soumettre à nouveau."
    end

    # Sauver le questionnaire
    save_this_quiz


    # Enregistrer le score dans le programme de l'utilisateur,
    # sauf si c'est un questionnaire multi et qu'il a déjà
    # été enregistré
    #
    # Attention : ça, ce sont les points pour le quiz, par
    # pour le travail qui peut en ajouter par ailleurs. Je
    # ne sais pas si c'est une bonne chose, mais elle peut
    # se produire en tout cas.
    unless quiz_points.nil? || (multi? && auteur_has_this_quiz?)
      auteur.add_points( quiz_points.freeze )
    end

    # Marquer le travail de l'auteur comme accompli.
    work.set_complete( addpoint = false )

    # Si c'est une validation des acquis et que le questionnaire
    # n'est pas validé (note insuffisante), il faut le reprogrammer
    # pour plus tard (quinze jours plus tard)
    # TODO : Remettre ça en place, ça ne fonctionne plus pour le
    # moment car les reprogrammations futures ne fonctionnent plus
    # dans le nouveau système.
    if type_validation == :validation_acquis && !questionnaire_valided?
      reprogrammer_questionnaire(15) # 15 = nombre de jours
    end


    flash "Votre questionnaire a été évalué et enregistré avec succès.<br />Vous trouverez ci-dessous votre résultat ainsi que les erreurs que vous avez pu commettre."

  rescue Exception => e
    error "# Un problème est survenu au cours de l'évaluation de votre questionnaire : #{e.message}."
    debug e
    false
  else
    true
  end


  # = main =
  #
  # Méthode principale appelée pour procéder au calcul
  # Note : les réponses se trouvent dans les paramètres, de façon
  # générale dans des paramètres "q-X_r-X" ou des valeurs pour
  # q-X quand ce sont des boutons radio.
  # Par exemple param('q-2') pourra valeur "4" si le choix 4 de
  # la question 2 a été sélectionné.
  def evalute_quiz

    # Pour indiquer à toutes les méthodes que c'est pour une
    # correction du questionnaire (cela permet à `<quiz>correction?`
    # de retourner true)
    @for_correction = true

    # Récolte des réponses par type de question
    @reponses_auteur  = {}
    # Nombre de points total marqués par l'user
    # Note : Peut être nil sur certains questionnaires, sans
    # que cela ne génère de problème.
    @auteur_points    = 0
    # Pour comptabiliser le nombre maximum de points possibles
    # Noter que c'est aussi une méthode-propriété qui fait ce
    # calcul, mais ici, on le fait en même temps que le reste.
    @max_points = 0

    # Sera mis à true si une erreur est trouvée. pour le moment,
    # une erreur n'est générée que lorsqu'une réponse n'a pas
    # été donnée. Dès qu'une réponse n'a pas été donnée
    # on interromp l'évaluation.
    une_erreur = false

    # Préfixe pour tous les champs.
    prefix = "quiz-#{id}"

    # Boucler sur chaque question du questionnaire courant
    questions.each do |question|

      # L'ID de la question
      qid = question.id

      # On récupère la valeur donnée à la question, qui doit
      # être forcément définie.
      hvalue = question.value

      # Attention, hvalue[:id] est un Fixnum, mais en cas de
      # menu select à multiple choix, c'est un Array qui contient
      # les Fixnum des identifiants de chaque item choisi.
      if hvalue[:error]
        une_erreur = true
        @reponses_auteur.merge!( qid => { qid:qid, type:'error' } )
      else
        # Pour remettre les réponses en cas de ré-affichage
        hvalue[:jid] = "#{hvalue[:tagname]}##{prefix}_#{hvalue[:jid]}"
        # Composition du Hash de réponse qui sera enregistré dans
        # la donnée de l'auteur et qui servira au calcul de son questionnaire,
        # et pour la méthode javascript qui remettra les valeurs si
        # nécessaire.
        hreponse = {
          qid:    qid,
          type:   hvalue[:type], # utile pour javascript
          max:    question.max_points, # peut être nil
          points: hvalue[:points],
          value:  hvalue[:rep_value]
        }
        # debug "hreponse : #{hreponse.inspect}"
        @reponses_auteur.merge!( qid => hreponse )
        @auteur_points  += hreponse[:points] unless hreponse[:points].nil?
        @max_points     += hreponse[:max]    unless hreponse[:max].nil?
      end

    end # /Fin de la boucle sur chaque question

    debug "@reponses_auteur : #{@reponses_auteur.pretty_inspect}"

    # Une erreur avec le questionnaire, c'est-à-dire que toutes les
    # réponses n'ont pas été fournie par l'utilisateur.
    # On ne doit pas comptabiliser le questionnaire, mais le
    # ré-afficher tel quel (avec les réponses déjà données) pour
    # que l'auteur le complète.
    if une_erreur
      @for_correction = false
      error "Merci de bien vouloir répondre à toutes les questions du formulaire (les questions sans réponses sont indiquées en rouge)."
      return false
    else
      # Le questionnaire a été rempli correctement
      return true
    end

  end

end #/Quiz
end #/Unan
