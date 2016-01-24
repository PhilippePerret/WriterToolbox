# encoding: UTF-8
=begin

Module de calcul d'un questionnaire

=end
require 'json'

class Unan
class Quiz

  attr_reader :user_reponses
  attr_reader :user_points

  # Les données à enregistrer dans la table de l'auteur,
  # de ses réponses au questionnaire courant
  def data2save
    @data2save ||= {
      quiz_id:    id,
      type:       type,
      max_points: max_points,
      reponses:   user_reponses.to_json,
      points:     user_points,
      created_at: NOW
    }
  end

  # = main =
  #
  # Méthode principale appelée pour procéder au calcul
  # Note : les données se trouvent dans les paramètres, de façon
  # générale dans des paramètres "q-X_r-X" ou des valeurs pour
  # q-X quand ce sont des boutons radio.
  # Par exemple param('q-2') pourra valeur "4" si le choix 4 de
  # la question 2 a été sélectionné.
  def evaluate
    # Récolte des réponses par type de question
    @user_reponses  = Hash::new
    # Nombre de points total marqués par l'user
    # Note : Peut être nil sur certains questionnaires, sans
    # que cela ne génère de problème.
    @user_points    = 0
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
        @user_reponses.merge!( qid => { qid:qid, type:'error' } )
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
        @user_reponses.merge!( qid => hreponse )
        @user_points += hreponse[:points] unless hreponse[:points].nil?
        @max_points  += hreponse[:max]    unless hreponse[:max].nil?
      end

    end # /Fin de la boucle sur chaque question

    if une_erreur
      # On ne doit pas comptabiliser le questionnaire puisqu'il y
      # a une erreur
      return false
    else
      # Le questionnaire a été rempli correctement, on :
      #   - comptabilise le résultat en point
      #   -
      #   - enregistre les réponses données, dans le détail
      # debug "@user_reponses: #{@user_reponses.inspect}"
      return true
    end

    # TODO Enregistrer le score dans le work de l'utilisateur
    # TODO Lui ajouter les points à son total de points (programme)
    # TODO Il faut marquer que l'utilisateur a fait ce questionnaire
    # (donc marquer le travail ended avec la date)

    # TODO Voir en fonction du type de questionnaire ce qu'il faut
    # dire à l'utilisateur. Par exemple, si c'est une simple prise
    # de renseignement, il n'y a rien à faire d'autre que de le remercier.
    # En revanche, si c'est un questionnaire de validation des acquis, à
    # l'opposé, il faut refuser le questionnaire s'il ne comporte pas le
    # nombre de points suffisant (au moins 12 sur 20 ?)
    return true
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
            unless hreponse.nil?
              return hreponse.merge(ref_balise)
            end
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
