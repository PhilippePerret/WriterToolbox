# encoding: UTF-8

# Si ce n'est pas un administrateur, on raise tout de suite
raise_unless_admin


case param(:want)
when 'question'
  db_relname  = param(:database_relname)
  db_relname != nil || raise('Il faut définir la base contenant la question.')
  question_id = param(:id)
  question_id != nil || raise('Il faut définir l’identifiant de la question !')
  dquestion = site.dbm_table(db_relname, 'questions').get(question_id.to_i)
  dquestion.each do |k, v|
    dquestion[k] = v.force_encoding('utf-8') if v.instance_of? String
  end
  # dquestion[:reponses] = JSON.parse(dquestion[:reponses])
  Ajax << {question: dquestion}
when 'quiz'
  Ajax << {message: "Je dois retourner un questionnaire"}
else
  Ajax << {error: "Je ne sais pas retourner #{param :want}"}
end
