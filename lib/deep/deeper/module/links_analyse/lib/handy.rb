# encoding: UTF-8
def say mess
  puts mess
end

# Pour réceptionner le débug
# Pour le moment, on n'en fait rien
def debug err
  message, backtrace =
    case err.respond_to?(:message)
    when true
      [err.message, err.backtrace.join("\n")]
    else
      [err, nil]
    end
  puts "\n\n### ERREUR ###"
  puts message
  puts backtrace if backtrace
  puts "### /ERREUR ###\n\n"
end
