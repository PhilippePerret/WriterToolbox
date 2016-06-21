# encoding: UTF-8
class Sync
  def synchronize_forum
    @report << "* Synchronisation du FORUM"
    if Sync::Forum.instance.synchronize(self)
      @report << "= Synchronisation du FORUM opérée avec SUCCÈS".in_span(class:'blue')
    else
      mess_err = "# ERREUR pendant la synchronisation du FORUM".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Forum
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0
    raise "Le forum n'est pas encore synchronisables. Implémenter la méthode synchronize dans #{__FILE__}"

    # On doit synchroniser toutes les tables distantes
    # vers locales.
    #
    # NOTES : on ne doit JAMAIS toucher les tables
    # distantes par ce biais.
    [
      'posts', 'posts_content', 'sujets',
      'follows', 'posts_votes'
    ].each do |table_name|
      @table_name = table_name
      reset
    end
    report "  = NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end

  def db_suffix
    @db_suffix ||= :forum
  end
end #/Filmodico
end #/Sync
