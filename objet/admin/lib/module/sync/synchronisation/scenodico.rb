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
    @nombre_synchronisations = 0

    # Puisque le scénodico ne peut être modifié qu'en online, on prend
    # les rangées distantes et on les compare aux rangées locales.
    dis_rows.each do |mid, dis_data|
      loc_data = loc_rows[mid]

      if loc_data.nil?
        # Donnée locale inexistante
        # => Il faut la créer en local
        # ===== ACTUALISATION ========
        @nombre_synchronisations += 1
        # ============================
        report "  = Mot #{dis_data[:mot]} ajouté en local."
      elsif loc_data != dis_data
        # Donnée locale différente de la donnée distante
        # => Il faut actualiser la donnée locale
        # ===== ACTUALISATION ========
        @nombre_synchronisations += 1
        # ============================
        report "  = Mot #{dis_data[:mot]} actualisé en local."
      else
        # Données identiques
        suivi "Mot ##{mid} “#{dis_data[:mot]}” loc/dis identiques"
      end
    end

    report "  NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}"
  rescue Exception => e
    error e.message
    false
  else
    true
  end

  def db_suffix   ; @db_suffix  ||= :biblio     end
  def table_name  ; @table_name ||= 'scenodico' end
end #/Scenodico
end #/Sync
