# encoding: UTF-8
class SyncRestsite
class Sync

  attr_reader :id
  attr_reader :data
  attr_reader :from
  attr_reader :vers
  attr_reader :sens
  attr_reader :raison
  attr_reader :rel_path

  def initialize data
    @id   = SyncRestsite::Sync.next_id
    @data = data.merge(id: @id)
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

end #/Sync
end #/SyncRestsite
