# encoding: UTF-8

require 'json'

class UnanAdmin
class Quiz
class Question

  def save
    debug "data2save : #{data2save.pretty_inspect}"
    if dinp[:id].nil_if_empty.nil?
      # => Nouvelle question
      data2save.merge!(created_at: NOW)
      dinp[:id] = Unan::table_questions.insert(data2save)
    else
      # => Actualisation de question
      Unan::table_questions.update(dinp[:id].to_i, data2save)
    end
    param( :question => dinp )
    flash "Question sauvegardée."
  end

  def data2save
    @data2save ||= {
      question:     dinp[:question].nil_if_empty,
      reponses:     reponses,
      type:         "#{dinp[:type_c]}#{dinp[:type_a]}",
      raison:       dinp[:raison],
      updated_at:   NOW
    }
  end

  def reponses
    @reponses ||= begin
      (1..nombre_reponses).collect do |ireponse|
        h = dinp["reponse_#{ireponse}".to_sym].to_sym
        h[:libelle] = h[:libelle].strip
        next nil if h[:libelle].empty?
        h[:id]      = h[:id].to_i
        h[:points]  = h[:points].to_i
        h
      end.compact.to_json
    end
  end

  def dinp # pour "Data IN Param"
    @dinp ||= param(:question)
  end

  def nombre_reponses
    @nombre_reponses ||= dinp[:nombre_reponses].to_i
  end

end #/Question
end #/Quiz
end #/UnanAdmin

if param(:operation) == 'save_question'
  UnanAdmin::Quiz::Question::new().save
end
