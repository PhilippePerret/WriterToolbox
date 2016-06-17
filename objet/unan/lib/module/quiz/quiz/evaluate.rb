# encoding: UTF-8
=begin

Module de calcul d'un questionnaire

=end
require 'json'

class Unan
class Quiz

  # Les réponses de l'utilisateur, après la soumission du
  # questionnaire.
  # Mais noter que cette propriété est invoquée aussi à la
  # construction du questionnaire, que ce soit pour les
  # corrections ou non, pour simplifier le code. C'est le code
  # qui est par exemple transmis à javascript pour remettre les
  # réponses qui ont été fournies par l'user.
  def auteur_reponses
    @auteur_reponses ||= begin
      uquiz = auteur.quizes(quiz_id: id).values.last
      uquiz.nil? ? Hash::new : uquiz.reponses
    end
  end

  # Les données du questionnaire à enregistrer dans la
  # table de l'auteur, de ses réponses au questionnaire
  # courant
  #
  # Pour le moment, si c'est un questionnaire de type
  # "multi" (ré-utilisable), on n'enregistre pas les
  # réponses.
  def data2save
    @data2save ||= {
      quiz_id:    id,
      work_id:    nil, # sera défini ci-dessous
      type:       type,
      reponses:   (multi? ? nil : auteur_reponses.to_json),
      points:     auteur_points,
      max_points: max_points,
      created_at: NOW
    }
  end

  # = main =
  #
  # Méthode principale appelée lorsque l'auteur soumet son
  # questionnaire.
  #
  # La méthode appelle l'évaluation du questionnaire (`evaluate`,
  # cf. plus bas), enregistre le résultat dans la table des quiz
  # de l'auteur et affiche un message de fin de questionnaire en
  # fonction du résultat.
  def evaluate_and_save
    if evaluate == true

      # Barrière pour voir si le questionnaire ne vient pas
      # d'être soumis.
      # Pour un questionnaire "multi", le temps doit être
      # réduit car on peut le soumettre à nouveau dans un temps
      # assez court correspondant à son remplissage.
      if quiz_existe_deja? && false == multi?
        soumis_recemment = auteur.table_quiz.count(where: "program_id = #{auteur.program.id} AND quiz_id = #{id} AND created_at > #{NOW - 1.day}") > 0
        return error "Votre questionnaire a déjà été enregistré.<br />Merci de ne pas le soumettre à nouveau." if soumis_recemment
      end

      # Si aucun travail n'existe pour ce quiz, c'est qu'il
      # vient d'être rempli et il faut créer un travail pour lui
      if work.nil?
        # Il faut retrouver l'identifiant absolu du abs_work
        # et le jour-programme correspondant au quiz (qui n'est
        # pas forcément aujourd'hui)
        # Noter que la tournure ci-dessous part du principe
        # qu'il ne peut pas y avoir 2 questionnaires identiques
        # en même temps.
        abs_work_id = nil
        indice_pday = nil
        bureau.current_pday.undone(:quiz).each do |wdata|
          if wdata[:item_id] == id
            abs_work_id = wdata[:id]
            indice_pday = wdata[:indice_pday]
            break
          end
        end
        if abs_work_id.nil? || indice_pday.nil?
          if OFFLINE
            error "Consulter le débug pour récolter certaines informations"
            debug "### ERREUR : Impossible de déterminer le travail absolu et le jour-programme"
            debug "Liste des travaux absolus inachevés au jour courant :\n #{bureau.current_pday.undone(:quiz).pretty_inspect}"
            debug "User : #{auteur.pseudo} (##{auteur.id})"
            debug "Travaux non"
          end
          raise "Impossible de déterminer le travail absolu et le jour-programme de ce questionnaire."
        end
        require './objet/unan/lib/module/work/create.rb'
        @work = create_new_work_for_user(
          user:         auteur,
          abs_work_id:  abs_work_id,
          indice_pday:  indice_pday
        )
      end

      # Enregistrer les données de ce questionnaire dans la
      # table de l'utilisateur
      auteur.table_quiz.insert(data2save.merge(work_id: work.id))

      # Enregistrer le score dans le programme de l'utilisateur,
      # sauf si c'est un questionnaire multi et qu'il a déjà
      # été enregistré
      #
      # Attention : ça, ce sont les points pour le quiz, par
      # pour le travail qui peut en ajouter par ailleurs. Je
      # ne sais pas si c'est une bonne chose, mais elle peut
      # se produire en tout cas.
      unless quiz_points.nil? || (multi? && quiz_existe_deja?)
        auteur.add_points( quiz_points.freeze )
      end
      # Marquer le travail (qui a généré le questionnaire) comme
      # accompli.
      #
      # NON : Surtout pas, sinon le quiz ne serait plus affiché et
      # aucun résultat ne serait donné à l'auteur. On marque donc
      # le travail fini après avoir affiché le résultat, dans la vue
      # ERB, en testant la propriété correction?
      #
      # Si c'est une validation des acquis et que le questionnaire
      # n'est pas validé (note insuffisante), il faut le reprogrammer
      # pour plus tard (quinze jours plus tard)
      if type_validation == :validation_acquis && !questionnaire_valided?
        debug "--> reprogrammer_questionnaire"
        reprogrammer_questionnaire(15) # 15 = nombre de jours
      end

      # Étudier et construire le retour en fonction du questionnaire
      # et du résultat de l'auteur.
      # Cf. dans le fichier `retour.rb`
      debug "--> commented_output"
      commented_output

      flash "Votre questionnaire a été évalué et enregistré avec succès.<br />Vous trouverez ci-dessous votre résultat ainsi que les erreurs que vous avez pu commettre."
      return true
    else
      false
    end
  rescue Exception => e
    error "# Un problème est survenu au cours de l'évaluation de votre questionnaire : #{e.message}."
    debug e
  end

  def quiz_existe_deja?
    @quiz_existe_deja ||= auteur.table_quiz.count(where: "program_id = #{auteur.program.id} AND quiz_id = #{id}") > 0
  end

  # Marquer le travail qui a conduit à ce questionnaire comme
  # exécuté. Noter qu'on le fait même quand c'est par exemple
  # une validation des acquis et qu'elle n'est pas réussie. Cela
  # reposera simplement le questionnaire plus tard, mais un questionnaire
  # est toujours enregistré comme record.
  #
  # Noter qu'on ne compte les points, dans le cas où c'est un
  # questionnaire ré-utilisable, que la première fois
  def mark_work_done
    return error( "Impossible de trouver le travail de ce questionnaire…" ) if work.nil?
    doit_ajouter_points = !(multi? && quiz_existe_deja?)
    work.set_complete( doit_ajouter_points )
  end

  # Méthode qui reprogramme le questionnaire pour plus tard lorsqu'il
  # n'a pas été rempli correctement (pour le type :validation_acquis)
  #
  # OBSOLÈTE : Pour le moment, on ne peut plus reprogrammer un
  # travail.
  def reprogrammer_questionnaire nombre_jours = 7
    return
    hnew_work = {
      program_id:   work.program.id,
      abs_work_id:  work.abs_work_id,
      status:       0,
      options:      "",
      points:       0,
      ended_at:     nil,
      created_at:   NOW + nombre_jours.days,
      updated_at:   NOW + nombre_jours.days
    }
    new_work = Unan::Program::Work::new(work.program, nil)
    new_work.instance_variable_set('@data2save', hnew_work)
    new_work_id = new_work.create
  end

  # = main =
  #
  # Méthode principale appelée pour procéder au calcul
  # Note : les réponses se trouvent dans les paramètres, de façon
  # générale dans des paramètres "q-X_r-X" ou des valeurs pour
  # q-X quand ce sont des boutons radio.
  # Par exemple param('q-2') pourra valeur "4" si le choix 4 de
  # la question 2 a été sélectionné.
  def evaluate

    # Pour indiquer à toutes les méthodes que c'est pour une
    # correction du questionnaire (cela permet à `<quiz>correction?`
    # de retourner true)
    @for_correction = true

    # Récolte des réponses par type de question
    @auteur_reponses  = Hash::new
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
    # été donnée.
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
        @auteur_reponses.merge!( qid => { qid:qid, type:'error' } )
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
        @auteur_reponses.merge!( qid => hreponse )
        @auteur_points  += hreponse[:points] unless hreponse[:points].nil?
        @max_points     += hreponse[:max]    unless hreponse[:max].nil?
      end

    end # /Fin de la boucle sur chaque question

    # Une erreur avec le questionnaire, c'est-à-dire que toutes les
    # réponses n'ont pas été fournie par l'utilisateur.
    # On ne doit pas comptabiliser le questionnaire
    if une_erreur
      @for_correction = false
      error "Merci de bien vouloir répondre à toutes les questions du formulaire (les questions sans réponses sont indiquées en rouge)."
      return false
    else
      # Le questionnaire a été rempli correctement
      return true
    end

  end


  class Question

    # Valeur de la réponse de la question
    # Cette méthode est appelée à la soumission du questionnaire pour
    # l'évaluer.
    # Elle retourne un {Hash} qui servira à :
    #   - tester la validité du questionnaire
    #   - composer la donnée qui servra à javascript pour resélectionner
    #     les valeurs s'il faut le faire
    #   - composer la donnée qui sera enregistrer dans la table des
    #     quiz de l'auteur
    #   - calculer la note du questionnaire au besoin
    #
    def value
      jid = "q_#{id}" # "quiz-X_" sera ajouté dans la méthode d'appel
      case type_c
      when "r"
        case type_a
        when "m"
          # Menu Select à choix unique
          # --------------------------
          # debug "-> select (unique)"
          val = param(:quiz)["q_#{id}".to_sym]
          ref_balise = {jid: jid, value:val, type:'sel', tagname:'select'}
          ireponse = val.split('_')[1].to_i
          ref_balise.merge!(rep_value: ireponse)
          # ATTENTION ICI, je ne suis pas certain que les réponses
          # fonctionnent par incréments réguliers… S'ils fonctionnent par
          # ID alors la méthode ci-dessous ne fonctionnera pas.
          hreponse = reponses[ireponse - 1]
          # Noter que pour un menu select, il n'y a toujours une
          # valeur définie.
          return hreponse.merge(ref_balise)
        else
          # debug "-> radio"
          val = param(:quiz)["q_#{id}".to_sym]
          ref_balise = {tagname:'input[type="radio"]', type:'rad',value:val, jid:"#{jid}_r_#{val}"}
          unless val.nil?
            ireponse = val.to_i
            ref_balise.merge!(rep_value: ireponse)
            hreponse = reponses[ireponse - 1]
            # debug "hreponse = #{hreponse.inspect}"
            return hreponse.merge(ref_balise) unless hreponse.nil?
          end
          return ref_balise.merge( error:true )
        end
      when "c"
        case type_a
        when "m"
          # debug "-> select (multiple)"
          vals = param(:quiz)[jid.to_sym]
          vals = [vals] unless vals.nil? || vals.instance_of?(Array)
          # debug "vals = #{vals.inspect}"
          ref_balise = { tagname:'select', type:'sem', jid:jid, value:vals }
          unless vals.nil?
            points  = 0
            ids     = Array::new
            vals.each do |val|
              irep = val.split('_')[1].to_i
              hrep = reponses[irep - 1]
              points += hrep[:points]
              ids << irep
            end
            return ref_balise.merge(points:points, id:ids, rep_value:ids)
          end
          # sinon
          return ref_balise.merge(error:true)
        else
          # debug "-> checkbox"
          vals    = Array::new
          ids     = Array::new
          points  = 0
          reponses.each do |reponse|
            name = "#{jid}_r_#{reponse[:id]}".freeze
            val = param(:quiz)[name.to_sym]
            # debug "param(:quiz)[name.to_sym] : #{param(:quiz)[name.to_sym].inspect}"
            if val == "on"
              vals  << name
              ids   << reponse[:id]
              points += reponse[:points]
            end
          end
          ref_balise = {tagname:'input[type="checkbox"]', type:'che', jid:jid, value:vals}
          unless vals.empty?
            return ref_balise.merge(points: points, id:ids, rep_value:ids)
          end
          return ref_balise.merge(error:true)
        end
      end
    end
  end #/Question

end #/Quiz
end #/Unan
