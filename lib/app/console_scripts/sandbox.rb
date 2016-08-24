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


def table_resultats_unan
  @table_resultats_unan ||= site.dbm_table(:quiz_unan, 'resultats', online = true)
end
def table_works_for uid
  tb_name = "unan_works_#{uid}"
  site.dbm_table(:users_tables, tb_name, online = true)
end
