# encoding: UTF-8
class SyncRestsite
class << self

  # Return false si les applications choisies ne sont pas bonnes,
  # true dans le cas contraire.
  # Si true, on procède à l'opération demandée.
  def applications_ok_or_raise
    app_source.exist?                       || raise('L’application source est introuvable.')
    app_destination.exist?                  || raise('L’application destination est introuvable.')
    app_source.name != app_destination.name || raise('Une application ne peut pas être synchronisée avec elle-même…')
  end

end #<< self
end #/SyncRestsite
