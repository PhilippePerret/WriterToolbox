# encoding: UTF-8
class Sync

  # {Array} Pour le rapport
  # @usage : sync.report << "message"
  attr_reader :report
  # {Array} Liste de messages de suivi d'opération
  # @usage : sync.suivi << "message"
  attr_reader :suivi
  # {Array} Message d'erreurs
  # @usage : sync.errors << "message"
  attr_reader :errors

  def initialize
    @suivi  ||= []
    @errors ||= []
    @report ||= []
  end

  # = main =
  #
  # Nouvelle méthode principale
  #
  def synchroniser

    # Synchronisation des tâches
    synchronize_taches    if param('sync_taches') == 'on'
    # Synchronisation des citations
    synchronize_citations if param('sync_citations') == 'on'
    # Narration
    synchronize_narration if param('sync_narration') == 'on'
    # Synchronisation du programme UN AN UN SCRIPT
    synchronize_uaus      if param('sync_uaus') == 'on'


    # Construction de la sortie
    build_output

  end


  def output; @output || "" end
  # Construit le message à écrire dans la page
  def build_output
    @output =
      build_output_errors +
      build_output_report +
      build_output_suivi
  end

  def build_output_errors
    return "" if errors.empty?
    c = ""

    c << "Erreurs au cours des opérations".in_h3
    c << errors.join("\n").in_pre(class: 'warning')

    return c

  end
  def build_output_report
    c = ""
    c << "Rapport de la synchronisation".in_h3
    c << report.join("\n").in_pre
  end
  def build_output_suivi
    c = ""

    c << "Suivi des opérations".in_h3
    c << suivi.join("\n").in_pre

    return c
  end

  # Méthode qui détruit tous les fichiers provisoires (pour
  # forcer le check)
  def reset_all
    folder_tmp.remove
    folder_tmp.build unless folder_tmp.exist?
  end

end #/Sync
