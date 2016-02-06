# encoding: UTF-8
raise_unless_admin

# require 'json'
Unan::require_module 'quiz'
UnanAdmin::require_module 'quiz'


class UnanAdmin
class Quiz

  # ---------------------------------------------------------------------
  #   Méthodes de classe
  # ---------------------------------------------------------------------
  class << self
    attr_accessor :current
    # Pour répondre à la route quiz/<id>/edit?in=unan_admin
    def get quiz_id
      self.current= Unan::Quiz::new(quiz_id)
    end
  end # << self

  # ---------------------------------------------------------------------
  #   Méthodes d'instance
  # ---------------------------------------------------------------------
  def destroy
    raise "Il faut définir l'identifiant." if id.nil?
    raise "Ce questionnaire est inconnu." unless exist?
    Unan::table_quiz.delete(id)
    param(:quiz => nil)
    flash "Questionnaire ##{id} détruit."
  rescue Exception => e
    error e.message
  end

  def save
    check_data || return

    # Parfois, on force l'enregistrement du questionnaire
    # sous un autre ID. Il faut donc vérifier, si l'identifiant
    # est fourni, si c'est bien une actualisation
    if new_version? || id == nil || !exist?
      if new_version?
        id_previous_version = "#{id}".to_i.freeze
        @id = nil
      end
      if !exist? && id != nil
        data2save.merge!(id: id)
      end
      data2save.merge!(created_at: NOW)
      @id = Unan::table_quiz.insert(data2save)
      dinp[:id] = @id
      param(:quiz => dinp)
    else
      Unan::table_quiz.update(id, data2save)
    end

    if new_version?
      previous_quiz = Unan::Quiz::new(id_previous_version)
      previous_quiz.set_next_version(@id)
      Unan::Quiz::new(@id).set_previous_version(id_previous_version)
      added_messages = " (nouvelle version du questionnaire ##{id_previous_version})"
    else
      added_messages = ""
    end
    "Questionnaire ##{id} enregistré#{added_messages}."
  end

  def data2save
    @data2save ||= {
      titre:          titre,
      type:           type,
      questions_ids:  questions_ids,
      points:         points,
      description:    description,
      options:        options,
      output:         nil,
      updated_at:     NOW
    }
  end

  def id            ; @id             ||= dinp[:id].nil_if_empty.to_i_inn   end
  def titre         ; @titre          ||= dinp[:titre].gsub(/"/, '“').nil_if_empty         end
  def type          ; @type           ||= dinp[:type]                       end
  def questions_ids ; @questions_ids  ||= dinp[:questions_ids].nil_if_empty end
  def description   ; @description    ||= dinp[:description].gsub(/"/, '“').nil_if_empty   end
  def points        ; @points         ||= dinp[:points].nil_if_empty.to_i   end
  # Reconstitution des options
  def options
    @options ||= begin
      # Construction des options
      opts = String::new
      [
        'description',
        'no_point_question',
        'no_titre',
        'desordre'
      ].each do |k|
        option_ok = dinp["option_#{k}".to_sym] == "on"
        opts << (option_ok ? "1" : "0")
      end
      debug "opts : #{opts}"
      opts
    end
  end

  def description?
    dinp[:option_description] == 'on'
  end
  def no_point_question?
    dinp[:option_no_point_question] == 'on'
  end


  def exist?
    Unan::table_quiz.count(where:{id: id}) > 0
  end

  def new_version?
    @for_new_version ||= (dinp.delete(:new_version) == "on")
  end

  def dinp
    @dinp ||= param(:quiz)
  end

  def check_data
    raise "Le titre doit être défini (même s'il n'est pas affiché)." if titre.nil?
    raise "Les IDs des questions doivent être donnés." if questions_ids.nil?
    raise "La description doit être donnée, pour être affichée." if description? && description.nil?
    raise "Il faut fixer le nombre de points, si les réponses n'en apportent pas." if no_point_question? && points.nil?
  rescue Exception => e
    error e
  else
    true
  end
end #/Quiz
end #/UnanAdmin

case param('operation')
when 'save_quiz'
  UnanAdmin::Quiz::new().save
when 'destroy_quiz'
  UnanAdmin::Quiz::new().destroy
end
