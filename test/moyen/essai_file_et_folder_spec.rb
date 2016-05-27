# encoding: UTF-8

# Juste pour se trouver dans une test-méthode car les
# méthode 'file' et 'folder' ne fonctionnent qu'à l'intérieur
# de ces test-méthodes
test_user 1 do
  description 'Test des méthodes de case `file` et `folder` (méthodes de tests)'
  file('./index.rb', 'Le fichier index principal').exists
  folder('./CRON').exists
  folder('./INEXISTANT').not_exists
  folder('./lib', 'Le dossier librairies principal').exists
  show 'Le fichier inexistant existe ? ' + file('./inexistant').exists?.inspect
  show 'Le dossier objet existe ? ' + folder('./objet').exists?.inspect
end
