=begin

  Pour définir le mode verbose/quiet :

      mode_verbose true/false
      
=end

# Pour écrire un message de succès en console
def success message
  verbose? || return
  puts "\e[32m#{message}\e[0m"
  sleep 0.1
end


def mode_verbose mode
  @mode_verbose = mode
end
def verbose?
  defined?(@mode_verbose) || begin @mode_verbose = true end
  @mode_verbose
end
