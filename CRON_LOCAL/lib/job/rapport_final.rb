# encoding: utf-8
=begin

  Module final pour faire un rapport à l'administrateur,
  détaillé s'il le faut.

=end
class LocCron

  # Méthode principale qui envoie le rapport à l'administrateur
  def rapport_final
    @nombre_erreurs ||= 0
    if @nombre_erreurs > 0

    end

    # Initialisation du rapport administrateur
    areport = String.new

    if File.exist?(logerrorpath)
      mess =
        if @nombre_erreurs > 1
          "#{@nombre_erreurs} erreurs se sont produites"
        else
          'Une erreur s’est produite'
        end
      areport << "<strong class='warning' style='display:block;margin:2em;border:1px solid red;font-size:13pt'>#{mess} au cours du dernier cron LOCAL…</strong>\n"
      areport << File.open(logerrorpath,'rb'){|f| f.read.force_encoding('utf-8')}
    end

    # On ajoute toujours le rapport normal s'il faut un rapport
    # complet. Sinon, on indique juste un message simple
    areport << File.open(logpath,'rb'){|f| f.read.force_encoding('utf-8')}

    # On transforme les retours chariot en DIV et on définit la
    # taille de la police.
    areport = areport.
      split("\n").
      collect{|p|"<div>#{p}</div>"}.join('').
      in_div(style: 'font-size: 12pt')
      
    # On envoie le rapport
    site.send_mail_to_admin(
      subject:        "RAPPORT CRON LOCAL #{NOW.as_human_date(true, true, ' ')}",
      message:        areport,
      formated:       true,
      force_offline:  true
    )

  end
end #/LocCron
