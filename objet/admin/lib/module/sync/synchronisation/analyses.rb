# encoding: UTF-8
class Sync
  def synchronize_analyses
    @report << "* Synchronisation des Analyses de films"
    if Sync::Analyses.instance.synchronize(self)
      @report << "= Synchronisation des Analyses de films OPÉRÉE AVEC SUCCÈS".in_span(class:'blue')
    else
      mess_err = "# ERREUR pendant la synchronisation des Analyses de films".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Analyses
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    raise "Les analyses de film ne sont pas encore synchronisables. Implémenter la méthode synchronize dans #{__FILE__}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end
end #/Filmodico
end #/Sync
