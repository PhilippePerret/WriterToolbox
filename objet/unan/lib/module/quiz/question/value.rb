# encoding: UTF-8
class Unan
class Quiz
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
        hreponse = real_array_reponses[ireponse - 1]
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
          hreponse = real_array_reponses[ireponse - 1]
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
            hrep = real_array_reponses[irep - 1]
            points += hrep[:points]
            ids << irep
          end
          return ref_balise.merge(points:points, id:ids, rep_value:ids)
        end
        # sinon
        return ref_balise.merge(error:true)
      else # type_a = c
        # debug "-> checkbox"
        vals    = []
        ids     = []
        points  = 0
        real_array_reponses.each do |reponse|
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

  # Le array dejsonné des réponses au questionnaire
  def real_array_reponses
    @real_array_reponses ||= begin
      arr = JSON.parse(reponses, symbolize_names: true)
      if arr.first.instance_of?(String)
        # Il arrive que les éléments intérieurs du Array n'aient
        # pas été transformés en Hash de données
        arr =
          arr.collect do |hstring|
            JSON.parse(hstring, symbolize_names: true)
          end
      end
      arr
    end
  end
end #/Question
end #/Quiz
end #/Unan
