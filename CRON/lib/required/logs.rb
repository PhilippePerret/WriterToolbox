# encoding: UTF-8
=begin

  Note : Ce fichier est chargé avant tous les autres, donc on
  peut l'utiliser très tôt dans le programme.

  Il est composé de deux méthodes principales : l'une s'occupe des
  messages "normaux" de traitement et l'autre s'occupe des erreurs
  qui surviennent au cours du programme.

  Ce module doit absolument rester *sans erreur* pour qu'on soit
  sûr que des messages soient enregistrés.

=end

class SafedLog
  def init
    File.open(safed_log_path, 'wb') do |f|
      f.write "SAFED LOG DU #{Time.now.strftime('%d %m %Y - %H:%M')}\n(Ce fichier est un log sûr qui devrait être créé quelles que soient les circonstances)\nRACINE : #{RACINE}\n\n"
    end
  end
  def add mess
    File.open(safed_log_path, 'a') do |f|
      f.write "#{mess}\n"
    end rescue nil
  end
  alias :<< :add

  # Pour envoyer le rapport de safed-log à l'administration
  # si demandé. C'est la constante SEND_SAFED_LOG définie dans
  # Cron/main.rb qui le détermine.
  def send_report
    content = File.open(safed_log_path,'r'){|f| f.read.force_encoding('utf-8')}

    content = <<-TXT
(Pour ne plus recevoir ce rapport, mettre la constante SEND_SAFED_LOG
 à false dans ./CRON/lib/required/Cron/main.rb.

 Actuellement, la valeur est de #{Cron::SEND_SAFED_LOG}.)

 #{content}"
    TXT
    MiniMail.new().send(
      content,
      "BOA - Safed-log du #{Time.now}"
    )
  rescue Exception => e
    error_log e, "Impossible d'envoyer le safed-log."
  end

  def safed_log_path
    @safed_log_path ||= "#{RACINE}/CRON/safed_log.log"
  end

end

class SafedErrorLog
  class << self
    # Pour savoir si une erreur s'est produite au cours
    # du cron-job.
    attr_accessor :error_occured

    def error err
      err =
        case err
        when String then err
        else err.message + "\n" + err.backtrace.join("\n")
        end
      @errors ||= []
      @errors << "[#{now_human}] #{err}"
    end

    def now_human
      @now_human ||= Time.now.strftime('%d %m %Y à %H:%M')
    end

    # Construit le rapport d'erreur qui sera envoyé à l'administration
    # Noter qu'il est envoyé de façon séparée par vraiment être mis
    # en évidence.
    def report_errors
      s = @errors.count > 1 ? 's' : ''
      '<div style="color:red">' +
      "<div style=\"margin-bottom:2em;\">#{@errors.count} erreur#{s} produite#{s} au cours du dernier cron du #{now_human} :</div>" +
      @errors.collect do |err|
        "<div># #{err.gsub(/\n/,'<br>')}</div>"
      end.join("\n") +
      '</div>'
    end

    def send_report_errors
      MiniMail.new().send(
        report_errors,
        "BOA - RAPPORT D'ERREUR du #{now_human}",
        {format: 'html'}
      )
    rescue Exception => e
      error_log e, "Impossible d'envoyer le rapport d'erreur"
    end
    
  end # << self

  # ---------------------------------------------------------------------
  #   INSTANCE
  # ---------------------------------------------------------------------

  def init
    File.open(safed_error_log_path, 'a') do |f|
      f.write "\n\n============ LOG ERROR #{now_human} ==============\n\n"
    end rescue nil
    @inited = true
  end

  # Pour ajouter un message d'erreur
  def add err, amorce = nil
    @inited || init
    if err.respond_to?(:backtrace) # une erreur quelconque
      err = err.message + "\n" + err.backtrace.join("\n")
    end
    err = "#{amorce} : #{err}" unless amorce.nil?
    File.open(safed_error_log_path, 'a') do |f|
      f.write "#{err}\n"
    end rescue nil
    self.class.error_occured = true
    self.class.error err
  end
  alias :<< :add

  def safed_error_log_path
    @safed_log_path ||= "#{RACINE}/CRON/safed_error_log.log"
  end
end

def safedlog
  @safedlog ||= SafedLog.new
end
def errorlog
  @errorlog ||= SafedErrorLog.new
end

# === Méthode principale ===
def safed_log mess
  safedlog.add mess
end
# Handy méthode pour enregistrer une erreur
# +mess+ peut être un message ou une erreur
def error_log(mess, amorce = nil)
  errorlog.add mess, amorce
end
alias :log_error :error_log

# On initialise le safedlog
safedlog.init
# Note : On n'initialise pas le log des erreurs
# car il doit toujours rester en place pour
# conserver toutes les erreurs qui se produisent
