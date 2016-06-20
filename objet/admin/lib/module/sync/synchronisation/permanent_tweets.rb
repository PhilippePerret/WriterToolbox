# encoding: UTF-8
class Sync
  def synchronize_permanent_tweets
    @report << "* Synchronisation des TWEETS PERMANENTS"
    if Sync::PTweets.instance.synchronize(self)
      @report << "= Synchronisation des TWEETS PERMANENTS opérée avec SUCCÈS".in_span(class:'blue')
    else
      mess_err = "# ERREUR pendant la synchronisation des TWEETS PERMANENTS".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class PTweets
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    raise "Les tweets permanents ne sont pas encore synchronisables. Implémenter la méthode synchronize dans #{__FILE__}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end
end #/Filmodico
end #/Sync
