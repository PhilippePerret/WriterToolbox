# encoding: utf-8
class LocCron

  attr_reader :nombre_erreurs

  # Pour enregistrer un message normal :
  #   log <le message>
  # Pour ajouter une précision au message suivant
  #   log <la précision>, :add
  # Pour enregistrer une erreur :
  #   log <message d'erreur>, <l'erreur>
  # Pour enregistrer une info (débug)
  #   log <message>, :info
  def log mess, type = :notice
    case type
    when :notice
      # Un message normal
      logref.puts "\n---[#{Time.now}] #{mess}\n"
    when :add
      logref.puts "    #{mess}\n"
    when :info
      logref.puts "    ((#{mess}))\n"
    else # :error
      # Un message d'erreur
      @nombre_erreurs ||= 0
      @nombre_erreurs += 1
      if type.respond_to?(:backtrace)
        type = type.message + "\n" + type.backtrace.join("\n")
      end
      mess_error = "\n\n###[#{Time.now}] #{mess} : #{type}\n"
      logref      .puts mess_error
      logerrorref .puts mess_error
    end
  end
  def logref
    @logref ||= File.open(logpath, 'a')
  end
  def logerrorref
    @logerrorref ||= File.open(logerrorpath, 'a')
  end
  def logpath
    @logpath ||= File.join(APP_FOLDER, 'CRON_LOCAL', 'log_main.log')
  end
  def logerrorpath
    @logerrorpath ||= File.join(APP_FOLDER, 'CRON_LOCAL', 'log_error.log')
  end

end #/LocCron
