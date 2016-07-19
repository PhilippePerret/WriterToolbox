# encoding: UTF-8
=begin

Pour ouvrir n'importe quel fichier dans n'importe quelle application,
mais seulement si l'on est un administrateur.

@usage

    site/open_file?path=le/path/du/fichier.ext&app=<l'application>

@note

    * Si aucun application n'est précisé, c'est TextMate (plutôt que
    Atom) qui est choisi, quel que soit les réglages de config.rb

    * `path` peut être remplacé par `file`

=end
raise_unless_admin

path = param(:path) || param(:file) || (raise "Aucun fichier n'est défini !" )
File.exist?(path) || path = File.expand_path(path)
debug "Path à ouvrir: #{path}"
if File.exist? path
  # osascript "tell application \\\"#{param(:app)}\\\" to open \\\"#{param(:path).gsub(/\//,':')}\\\""
  app = param(:app) || "TextMate"
  cmd = "open -a #{app} #{path}"
  debug "Command: #{cmd}"
  # On exécute la commande
  `#{cmd}`
  flash "Ouverture de #{path} dans #{app}"
else
  error "La page #{path} est introuvable. Impossible de l'ouvrir."
end
