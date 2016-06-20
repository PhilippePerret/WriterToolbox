# encoding: UTF-8
class Sync
  def synchronize_filmodico
    @report << "* Synchronisation du FILMODICO"
    if Sync::Filmodico.instance.synchronize(self)
      @report << "= Synchronisation du FILMODICO OPÉRÉE AVEC SUCCÈS".in_span(class:'blue')
    else
      mess_err = "# ERREUR pendant la synchronisation du FILMODICO".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Filmodico
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    raise "Le filmodico n'est pas encore synchronisable. Implémenter la méthode synchronize dans #{__FILE__}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end
end #/Filmodico
end #/Sync
