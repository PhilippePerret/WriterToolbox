# encoding: UTF-8
class Sync
  def synchronize_scenodico
    @report << "* Synchronisation du SCÉNODICO"
    if Sync::Scenodico.instance.synchronize(self)
      @report << "= Synchronisation du SCÉNODICO OPÉRÉE AVEC SUCCÈS".in_span(class:'blue')
    else
      mess_err = "# ERREUR pendant la synchronisation du SCÉNODICO".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Scenodico
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    raise "Le Scénodico n'est pas encore synchronisable. Implémenter la méthode synchronize dans #{__FILE__}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end
end #/Scenodico
end #/Sync
