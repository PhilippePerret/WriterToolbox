# encoding: UTF-8
class SyncRestsite
class Sync


  def human_raison
    case raison
    when :outofdate then 'out of date'
    when :unknown   then 'inexistant'
    else 'raison inconnue'
    end
  end
end #/Sync
end #/SyncRestsite
