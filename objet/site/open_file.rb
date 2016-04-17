# encoding: UTF-8
=begin

Pour ouvrir n'importe quel fichier dans n'importe quelle application,
mais seulement si l'on est un administrateur.

@usage

    site/open_file?path=le/path/du/fichier.ext&app=<l'application>
=end
raise_unless_admin

def osascript(script)
  command = "osascript -e \"#{script}\" 2>&1"
  debug "command: #{command}"
  res = `#{command}`
  debug "res: #{res.inspect}"
end

if File.exist? param(:path)
  # osascript "tell application \\\"#{param(:app)}\\\" to open \\\"#{param(:path).gsub(/\//,':')}\\\""
  `open -a #{param :app} #{param :path}`
  flash "Ouverture de #{param :path} dans #{param(:app)}"
else
  error "La page #{param :path} est introuvable. Impossible de l'ouvrir."
end

redirect_to :last_route
