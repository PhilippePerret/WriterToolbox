# encoding: UTF-8
site.require_objet 'unan'
site.require 'form_tools'
Unan::require_module 'quiz'

class Unan
class Quiz
class Question
  def as_li_item
    mark_id = "[#{id}]".in_span(class:'tiny')
    ("#{mark_id} #{question} #{lien_edit('[edit]')}".in_span(class:'small')).in_li
  end
end #/Question
end #/Quiz
end #/Unan

# Retourne le code HTML pour le filtre des questions
# Ce filtrage peut se faire suivant trois caractéristiques :
#   - le type de question
#   - le titre
#   - l'identifiant d'un questionnaire
def boite_filtre
  form.prefix = "filtre"
  (
    "filtrer_items".in_hidden(name:'operation') +
    form.field_text("Contient", 'question', nil) +
    form.field_select("Type", 'type', nil, {values: Unan::Quiz::TYPES}) +
    form.submit_button("Filtrer", class_button:'small')
  ).in_form(action:"question/list?in=unan_admin/quiz", class:'', style:"width:45%;border:1px solid;display:block;text-align:left;margin-left:40%").in_div(class:'tiny')
end

def liste_questions
  # On traite tous les questionnaires pour obtenir les
  # versions précédentes aussi et les afficher, mais en plus petit
  #
  data_request = {colonnes: [:id]}
  # On applique le filtre s'il le faut
  if param(:filtre)
    filtre = param(:filtre)
    content_searched  = filtre[:question].nil_if_empty
    type_searched     = filtre[:type].to_i
    type_searched = nil if type_searched == 0
    if content_searched.nil? && type_searched.nil?
      # Peut permettre de revenir à la liste complète
      # donc ne rien faire
    else
      where = Array::new
      unless content_searched.nil?
        where << "question LIKE '%#{content_searched}%'"
        data_request.merge!(nocase:true)
      end
      where << "SUBSTR(type,1,1) = #{type_searched}" unless type_searched.nil?
      unless where.empty?
        where = where.join(' AND ')
        data_request.merge!(where:where)
      end
    end
  else
    # Ne rien faire
  end
  # debug "data_request : #{data_request.inspect}"
  # -> MYSQL UNAN !!!
  ::Unan::table_questions.select(data_request).collect do |qid, hquest|
    iquestion = ::Unan::Quiz::Question::new(qid)
    # On traite un quiz qui est une version finale
    iquestion.as_li_item
  end.join
end

case param(:operation)
when "filtrer_items"
  filtre = param(:filtre)
end
