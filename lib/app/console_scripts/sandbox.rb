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


fpath = '/Users/philippeperret/Library/Mobile Documents/com~apple~CloudDocs/NARRATION/XDIVERS/Films_TM/Rocky/rocky.film'

site.require_objet 'analyse'
FilmAnalyse.require_module 'timeline_scenes'
FilmAnalyse.from_tm_to_timeline fpath
log FilmAnalyse.args_tm.inspect
