# encoding: UTF-8

class CRON2
    class Log
        class << self
            def add mess, options
                is_error = false
                case options
                when NilClass
                when Symbol
                else
                    if options.respond_to?(:backtrace)
                        mess = "### #{mess} : #{options.message} (voir le détail dans le fichier cron_error.log)"
                        mess_error = "#{mess} : #{options.message}\n" + options.backtrace.join("\n")
                        is_error = true
                    end
                end
                # Ecriture des messages
                logref.puts "---[#{Time.now}] #{mess}"
                logerrorref.write "---[#{Time.now}] #{mess_error}" if is_error
            end #/ add

            def logpath
                @logpath ||= File.join(THIS_FOLDER, 'cronjob.log')
            end
            def logerrorpath
                @logerrorpath ||= File.join(THIS_FOLDER, 'cron_error.log')
            end
            def logref
                @logref ||= begin 
                              rf = File.open(logpath, 'a')
                              rf.write("\n\n\n======= CRON-JOB du #{Time.now} =========\n\n")
                              rf
                            end
            end
            def logerrorref
                @logerrorref ||= begin
                                     rf = File.open(logerrorpath, 'a')
                                     rf.write("\n\n\n========= CRON-ERRORS du #{Time.now} ======\n\n")
                                     rf
                                 end
            end
        end #/ << self
    end #/CRON2::Log
end #/CRON2

def log mess, options = nil
    CRON2::Log::add mess, options
end
