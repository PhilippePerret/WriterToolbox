# # encoding: UTF-8
# =begin
#
#   @usage
#       Dans Atom       CMD + i
#       Dans TextMate   CMD + R
#
#
#   TODO LIST
#     Traiter les routes qui commencent par "#"
#     Pour le moment, elles ne semblent pas générer de problème,
#     ce qui est plutôt bizarre…
#
# =end
def log str
  console.sub_log "#{str}<br>"
end
# Enregsitre le quiz de données +hquiz+ et retourne l'identifiant
# (qui ne doit pas avoir changé, en fait)
def save_quiz hquiz
  quiz = Quiz.new(nil, 'unan')
  # On doit juste supprimer la propriété :points
  hquiz.delete :points
  hquiz.delete :output
  # Il faut régler les options pour qu'elles répondent au nouveau format
  options = '01--01'
  # On doit ajouter la propriété :groupe
  hquiz.merge!(
    groupe: 'unan',
    options:  options
    )
  # On peut sauver les données du quiz
  if Quiz.table_quiz.count(where: {id: hquiz[:id]})
    Quiz.table_quiz.update(hquiz[:id], hquiz)
  else
    Quiz.table_quiz.insert(hquiz)
  end
end


site.require_objet 'quiz'
Quiz.suffix_base= 'unan'

table_quiz_old = site.dbm_table(:unan, 'quiz')
def table_questions_old
  @table_questions_old ||= site.dbm_table(:unan, 'questions')
end
def table_questions_new
  @table_questions_new ||= site.dbm_table(:quiz_unan, 'questions')
end

# Méthode qui sauvegarde toutes les questions (rappel : ces questions
# ne sont pas liées aux quiz, elles peuvent être utilisées par n'importe
# quel quiz)
def save_all_questions
  # --- Récupération des questions ---

  # On peut copier toutes les questions
  table_questions_old.select().each do |hquestion|
    log "Enregistrement de la question #{hquestion[:question]}"
    # log hquestion.inspect
    hquestion.merge!(groupe: 'unan')
    reps =
      JSON.parse(hquestion[:reponses]).collect do |h|
        h.instance_of?(Hash) || h = JSON.parse(h)
        log "h = #{h.inspect}:#{h.class}"
        libelle = h.delete('libelle')
        points  = h.delete('points')
        h.merge!('lib' => libelle, 'pts' => points)
        h
      end
    hquestion[:reponses] = reps.to_json
    log hquestion.inspect
    if table_questions_new.count(where: {id: hquestion[:id]}) > 0
      table_questions_new.update(hquestion[:id], hquestion)
    else
      table_questions_new.insert(hquestion)
    end
  end
end

def save_all_quiz
  table_quiz_old.select.each do |hquiz|
    log "Enregistrement du quiz #{hquiz[:titre]} (##{hquiz[:id]})"
    quiz_id = hquiz[:id]
    save_quiz hquiz
  end
end

# save_all_quiz

save_all_questions
