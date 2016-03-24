# encoding: UTF-8
=begin

Méthodes générales pratiques pour les fichiers

=end

# Retourne le path complet au fichier
# +relpath+ en chemin relatif considéré à partir du dossier
# contenant le script appelant. Équivalent à require_relative mais
# retourne un path.
# Comme il peut y avoir plusieurs méthodes appelante, on passe
# en revue le `caller` jusqu'à trouver relpath
# Si +base+ est fourni, c'est le fichier duquel est appelé la
# méthode, c'est-à-dire `__FILE__`
def _( relpath, base = nil )
  # debug "caller : #{caller.inspect}"
  if base.nil?
    caller.each do |tripath|
      debug "tripath: #{tripath}"
      dpath = File.dirname( tripath.split(":").first )
      ptest = File.join( dpath, relpath )
      # debug "ptest: #{ptest}"
      return ptest if File.exist?(ptest)
    end
    error "Impossible de trouver le fichier relatif `#{relpath}`…"
    if user.admin?
      error "Pour palier ce problème, essayer de transmettre un second argument `__FILE__` à la méthode `_`. Si l'appel se fait depuis un fichier ERB, c'est obligatoire."
    end
    return nil # non trouvé
  else
    return File.join(File.dirname(File.expand_path(base)), relpath)
  end
end
