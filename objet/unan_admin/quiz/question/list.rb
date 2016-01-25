# encoding: UTF-8
site.require_objet 'unan'
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

def liste_questions
  # On traite tous les questionnaires pour obtenir les
  # versions précédentes aussi et les afficher, mais en plus petit
  ::Unan::table_questions.select(colonnes:[:id]).collect do |qid, hquest|
    iquestion = ::Unan::Quiz::Question::new(qid)
    # On traite un quiz qui est une version finale
    iquestion.as_li_item
  end.join
end
