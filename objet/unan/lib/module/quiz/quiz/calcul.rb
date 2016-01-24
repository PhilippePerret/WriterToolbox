# encoding: UTF-8
=begin

Module de calcul d'un questionnaire

=end
class Unan
class Quiz

  # = main =
  #
  # Méthode principale appelée pour procéder au calcul
  # Note : les données se trouvent dans les paramètres, de façon
  # générale dans des paramètres "q-X_r-X" ou des valeurs pour
  # q-X quand ce sont des boutons radio.
  # Par exemple param('q-2') pourra valeur "4" si le choix 4 de
  # la question 2 a été sélectionné.
  def calcule
    # TODO Prendre le nombre de questions (param(:quiz)[:nombre_questions])
    # Est-ce vraiment nécessaire, entendu qu'il faut de toute façon
    # charger le questionnaire pour pouvoir connaitre le nombre de
    # points de chaque question (et il est hors de question de
    # l'inscrire dans le code lui-même)

      # TODO Calculer la valeur de chaque question

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
  end


  class Question
    # Valeur de la réponse de la question
    def value
      jid = "q_#{id}" # "quiz-X_" sera ajouté dans la méthode d'appel
      case type_c
      when "r"
        case type_a
        when "m"
          # Menu Select à choix unique
          # --------------------------
          debug "-> select (unique)"
          val = param(:quiz)["q_#{id}".to_sym]
          ref_balise = {jid: jid, value:val, type:'select', tagname:'select'}
          ireponse = val.split('_')[1].to_i

          # ATTENTION ICI, je ne suis pas certain que les réponses
          # fonctionnent par incréments réguliers… S'ils fonctionnent par
          # ID alors la méthode ci-dessous ne fonctionnera pas.
          hreponse = reponses[ireponse - 1]
          # Noter que pour un menu select, il n'y a toujours une
          # valeur définie.
          return hreponse.merge(ref_balise)
        else
          debug "-> radio"
          val = param(:quiz)["q_#{id}".to_sym]
          ref_balise = {tagname:'input[type="radio"]', type:'radio',value:val, jid:"#{jid}_r_#{val}"}
          unless val.nil?
            ireponse = val.to_i
            hreponse = reponses[ireponse - 1]
            debug "hreponse = #{hreponse.inspect}"
            unless hreponse.nil?
              return hreponse.merge(ref_balise)
            end
          end
          return ref_balise.merge( error:true )
        end
      when "c"
        case type_a
        when "m"
          debug "-> select (multiple)"
          vals = param(:quiz)[jid.to_sym]
          vals = [vals] unless vals.nil? || vals.instance_of?(Array)
          debug "vals = #{vals.inspect}"
          ref_balise = {tagname:'select', type:'select_multiple', jid:jid, value:vals}
          unless vals.nil?
            points  = 0
            ids     = Array::new
            vals.each do |val|
              irep = val.split('_')[1].to_i
              hrep = reponses[irep - 1]
              points += hrep[:points]
              ids << irep
            end
            return ref_balise.merge(points:points, id:ids)
          end
          # sinon
          return ref_balise.merge(error:true)
        else
          debug "-> checkbox"
          vals    = Array::new
          ids     = Array::new
          points  = 0
          reponses.each do |reponse|
            name = "#{jid}_r_#{reponse[:id]}".freeze
            debug "name : #{name}"
            val = param(:quiz)[name.to_sym]
            debug "param(:quiz)[name.to_sym] : #{param(:quiz)[name.to_sym].inspect}"
            if val == "on"
              vals  << name
              ids   << reponse[:id]
              points += reponse[:points]
            end
          end
          debug "vals = #{vals.inspect}"
          ref_balise = {tagname:'input[type="checkbox"]', type:'checkbox', jid:jid, value:vals}
          unless vals.empty?
            return ref_balise.merge(points: points, id:ids)
          end
          return ref_balise.merge(error:true)
        end
      end
    end
  end #/Question

end #/Quiz
end #/Unan
