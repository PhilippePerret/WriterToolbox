# encoding: UTF-8


def app_source
  @app_source ||= begin
    debug "param(:app_source) : #{param(:app_source).inspect}"
    SyncRestsite::App.new(param(:app_source).to_sym)
  end
end
def app_destination
  @app_destination ||= begin
    SyncRestsite::App.new(param(:app_destination).to_sym)
  end
end
