# encoding: UTF-8
class SyncRestsite
class Sync
class << self

  def next_id
    @next_id ||= 0
    @next_id += 1
  end

end #/<< self
end #/Sync
end #/SyncRestsite
