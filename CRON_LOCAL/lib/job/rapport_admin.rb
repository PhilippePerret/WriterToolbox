# encoding: UTF-8
=begin

  Module final pour faire un rapport à l'administrateur,
  détaillé s'il le faut.

=end
class LocCron

  # Méthode principale qui envoie le rapport à l'administrateur
  def rapport_admin
    if @nombre_erreurs > 0

    end

    # Initialisation du rapport administrateur
    areport = String.new

    if File.exist?(logerrorpath)
      areport << "<strong class='warning' style='display:block;margin:2em;border:1px solid red;'>#{@nombre_erreurs} se sont produites lors du dernier cron LOCAL…</strong>"
      areport << File.open(logerrorpath,'rb'){|f| f.read.force_encoding('utf-8')}
    end

    # On ajoute toujours le rapport normal s'il faut un rapport
    # complet. Sinon, on indique juste un message simple
    areport << File.open(logpath,'rb'){|f| f.read.force_encoding('utf-8')}

    # On envoie le rapport
    site.send_mail_to_admin(
      subject:        "RAPPORT CRON LOCAL #{NOW.as_human_date(true, true, ' ')}",
      message:        areport,
      formated:       true,
      force_offline:  true
    )

  end
end #/LocCron
