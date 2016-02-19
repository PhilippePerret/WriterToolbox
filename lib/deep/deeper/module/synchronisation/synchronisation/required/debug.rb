# encoding: UTF-8
=begin
Noter que les librairies en sont pas chargées pour la synchro,
donc il faut implémenter ces méthodes
=end
def debug str
  @reffile ||= File.open('./tmp/log/synchro.log', 'a')
  @reffile.puts str
end