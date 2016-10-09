# encoding: UTF-8
class SyncRestsite
class App

  attr_reader :id

  # Instanciation de l'application avec son identifiant dans
  # la constante SyncRestSite::APPLICATIONS
  #
  def initialize app_id
    debug "app_id : #{app_id.inspect}"
    app_id = app_id.to_sym
    @id = app_id
    @data = SyncRestsite::APPLICATIONS[app_id]
  end

end #/App
end #/SyncRestsite
