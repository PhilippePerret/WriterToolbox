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
  end # << self
end

def log mess
  Log::log mess
end
