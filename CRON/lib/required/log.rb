# encoding: UTF-8

class Log
  class << self
    def log mess
      reflog.puts "#{mess}"
    end
    def reflog
      @reflog ||= init_reflog
    end
    def init_reflog
      ref = File.open(reflog_path, 'a')
      now_humain = Time.now.strftime("%d %m %Y - %H:%M")
      ref.write( "\n\n" + ("="*10) + " CRON JOB DU #{now_humain} " + ("="*10) + "\n\n" )
      ref
    end
    def reflog_path
      @reflog_path ||= File.join(THIS_FOLDER, "log-#{Time.now.to_i}.log")
    end

    # Obtenir le contenu du fichier log
    # DOnc il faut suspendre son ouverture pour pouvoir le lire puis
    # reprendre son ouverture.
    # Cette méthode est utilisée en fin de processus pour récupérer
    # le log pour le rapport d'administration
    def get_content
      reflog.close
      @reflog = nil
      content = SuperFile::new(reflog_path).read
      @reflog = File.open(reflog_path, 'a')
      return content
    end
  end # << self
end

def log mess
  Log::log mess
end
