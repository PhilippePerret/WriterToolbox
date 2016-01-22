# encoding: UTF-8
raise_unless_admin

require 'json'
Unan::require_module 'quiz'

class UnanAdmin
class Quiz
class Question

  # ---------------------------------------------------------------------
  #   Méthodes de classe
  # ---------------------------------------------------------------------
  class << self
    def destroy question_id
      if question_id.nil?
        error "Il faut indiquer l'identifiant de la question à détruire…"
        return
      elsif Unan::table_questions.count(where:{id: question_id}) == 0
        flash "La question ##{question_id} n'existe pas ou plus."
      else
        Unan::table_questions.delete(question_id)
        flash "Question ##{question_id} détruite."
      end
      param(:question => nil)
    end
  end # << self

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  def save
    check_data2save || return
    # debug "data2save : #{data2save.pretty_inspect}"
    if dinp[:id].nil_if_empty.nil?
      # => Nouvelle question
      data2save.merge!(created_at: NOW)
      dinp[:id] = Unan::table_questions.insert(data2save)
    else
      # => Actualisation de question
      Unan::table_questions.update(dinp[:id].to_i, data2save)
    end
    param( :question => dinp.merge(reponses: reponses) )
    flash "Question ##{dinp[:id]} sauvegardée."
  end

  def data2save
    @data2save ||= {
      question:     dinp[:question].gsub(/"/, '“').nil_if_empty,
      reponses:     reponses,
      type:         "#{dinp[:type_c]}#{dinp[:type_a]}#{dinp[:type_f]}",
      raison:       dinp[:raison],
      updated_at:   NOW
    }
  end

  def check_data2save
    d = data2save # + court
    raise "La question doit être définie."  if d[:question].nil?
    raise "Il faut au moins une réponse."   if nombre_reponses == 0
  rescue Exception => e
    error e.message
  else
    true
  end

  # Prépare le champ réponses qui  contient chaque réponse
  # Chaque réponse est un objet définissant :id, :libelle et
  # :points.
  def reponses
    @reponses ||= begin
      (1..nombre_reponses).collect do |indice_rep|
        h = dinp["reponse_#{indice_rep}".to_sym].to_sym
        h[:libelle] = h[:libelle].strip.gsub(/"/, '“')
        next nil if h[:libelle].empty?
        h[:id]      = indice_rep.freeze
        h[:points]  = h[:points].to_i.freeze
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

case param(:operation)
when 'save_question'
  UnanAdmin::Quiz::Question::new().save
when 'destroy_question'
  UnanAdmin::Quiz::Question::destroy(param(:question)[:id].to_i_inn)
end
