# encoding: UTF-8
# require 'json'

case param(:want)
when 'question'
  db_relname  = param(:database_relname)
  db_relname != nil || raise('Il faut définir la base contenant la question.')
  question_id = param(:id)
  question_id != nil || raise('Il faut définir l’identifiant de la question !')
  flash "Je dois retourner la question #{question_id} de la base #{db_relname}."
  dquestion = site.dbm_table(db_relname, 'questions').get(question_id.to_i)
  dquestion.each do |k, v|
    dquestion[k] = v.force_encoding('utf-8') if v.instance_of? String
  end
  Ajax << {question: dquestion}
when 'quiz'
  Ajax << {message: "Je dois retourner un questionnaire"}
else
  Ajax << {error: "Je ne sais pas retourner #{param :want}"}
end
