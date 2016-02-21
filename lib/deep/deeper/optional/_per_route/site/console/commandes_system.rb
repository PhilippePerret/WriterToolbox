# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def debug_sfile
    @debug_sfile ||= SuperFile::new("./debug.log")
  end
  def read_debug
    if debug_sfile.exist?
      sub_log debug_sfile.read.split("\n").collect{|p| p.in_div}.join("")
    else
      sub_log "Aucun fichier log à lire."
    end
    "OK"
  end

  def destroy_debug
    debug_sfile.remove if debug_sfile.exist?
    sub_log "Fichier débug détruit avec succès." unless debug_sfile.exist?
    "OK"
  end

end #/Console
end #/Admin
end #/SiteHtml
