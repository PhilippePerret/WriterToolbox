# encoding: UTF-8
safed_log "-> #{__FILE__}"
APP_FOLDER  = File.expand_path( File.dirname(THIS_FOLDER) )

# Pour que le mail soit envoyé
ONLINE      = true
OFFLINE     = false

safed_log "<- #{__FILE__}"

# Pour que le programme sache qu'il s'agit du cronjob
CRONJOB = true
