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
# 
# def table_questions_new
#   @table_questions_new ||= site.dbm_table(:quiz_unan, 'questions')
# end
#
# table_questions_new.select.each do |hquestion|
#   qid = hquestion[:id]
#   log "Question ##{qid} #{hquestion[:question]} - #{hquestion[:type]}"
#   # rl1 => 1rh0
#   # rc1 => 1rv0
#   old_type = hquestion[:type]
#   type_c, type_a, type_q = old_type.split('')
#   new_type_a =
#     case type_a
#     when 'c' then 'v'
#     else 'h'
#     end
#   new_type = "#{type_q}#{type_c}#{new_type_a}0"
#   log "#{old_type} -> #{new_type}"
#   datan = {
#     type:       new_type,
#     updated_at: NOW
#   }
#   table_questions_new.update(qid, datan)
# end
