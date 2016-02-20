# encoding: UTF-8
=begin
Noter que les librairies en sont pas chargées pour la synchro,
donc il faut implémenter ces méthodes
=end
def debug str
  @reffile ||= File.open(path_log, 'a')
  @reffile.puts str
end
def path_log
  @path_log ||= begin
    File.join(folder_log, 'synchronisation.log')
  end
end
def folder_log
  @folder_log ||= begin
    d = File.join('.', 'tmp', 'log')
    # On crée le dossier s'il n'existe pas
    `mkdir -p "#{d}"`
    d
  end
end
