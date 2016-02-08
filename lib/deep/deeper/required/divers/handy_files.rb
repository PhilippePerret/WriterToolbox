# encoding: UTF-8
=begin

Méthodes générales pratiques pour les fichiers

=end

# Retourne le path complet au fichier
# +relpath+ considérant que
# C'est équivalent à require_relative mais
# en retournant un path.
def _( relpath )
  # debug "caller : #{caller.inspect}"
  first_path = caller.first.split(":").first
  File.join(File.dirname(first_path), relpath)
end
