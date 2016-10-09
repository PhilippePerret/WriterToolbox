# encoding: UTF-8
=begin
  Module définissant toutes les opérations possibles (qui peuvent
  être atteintes par les boutons principaux)
=end
class SyncRestsite
class << self

  def compare
    proceed_compare
    flash "Comparaison de #{app_source.name} avec #{app_destination.name}."
  rescue Exception => e
    debug e
    error "La comparaison n'a pas pu se faire : #{e.message}"
  else
    true
  end
  def synchronize
    proceed_synchronize
    flash "Synchronisation de #{app_source.name} avec #{app_destination.name}"
  rescue Exception => e
    debug e
    error "La synchronisation n'a pas pu se faire : #{e.message}"
  else
    true
  end
end #/<< self
end #SyncRestsite
