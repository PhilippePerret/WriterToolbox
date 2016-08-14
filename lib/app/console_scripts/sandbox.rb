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
# # ---------------------------------------------------------------------
#
#
#
#
# # ---------------------------------------------------------------------

site.require_module 'ranking'

def log str
  console.sub_log "#{str}<br>"
end


# Initialisation (absolument nécessaire pour supprimer les
# anciens résultats)
Ranking.init



[
    'scénario'
    # 'script'
].each do |recherche|
  rank = Ranking.new(recherche)
  rank.analyze
  log '<pre>' + rank.result + '</pre>'
end
