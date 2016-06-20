# encoding: UTF-8
class Sync
  def synchronize_affiches
    @report << "* Synchronisation des AFFICHES de films"
    if Sync::Affiches.instance.synchronize(self)
      @report << "= Synchronisation des AFFICHES de films OPÉRÉE AVEC SUCCÈS".in_span(class:'blue')
    else
      mess_err = "# ERREUR pendant la synchronisation des AFFICHES de films".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Affiches
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    raise "Les affiches de film ne sont pas encore synchronisables. Implémenter la méthode synchronize dans #{__FILE__}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end
end #/Filmodico
end #/Sync
