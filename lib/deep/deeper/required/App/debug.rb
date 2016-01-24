# encoding: UTF-8
class App

  # Pour pouvoir utiliser app.debug (rappel : App est un singleton)
  def debug
    @debug ||= Debug::new
  end

  # ---------------------------------------------------------------------
  #   App::Debug
  # ---------------------------------------------------------------------
  class Debug
    def initialize
      @messages = Array::new
    end
    def add mess
      case mess
      when String
        # rien à faire
      when SQLite3::SQLException then
        mess = mess.message # pour le moment
      else
        if mess.respond_to?(:message)
          mess = mess.message + "\n\n" + mess.backtrace.join("\n")
        else
          mess = mess.to_s
        end
      end

      mess += "\n"

      # mess = mess.class.to_s
      @messages << mess
      write mess
    end
    def output
      return "" if @messages.empty?
      @messages.join('')
    end
    def write mess
      reffile.write "-- #{mess}"
    end
    def reffile
      @reffile ||= init_reffile
    end
    def init_reffile
      rf = File.open(file_path,'a')
      rf.write "\n\n=== DEBUG DU #{Time.now.strftime('%d %m %Y - %H:%M:%S')} ===\n\n"
      return rf
    end
    def file_path
      @file_path ||= File.join('.','debug.log')
    end
  end
end
