# encoding: UTF-8
class Forum
class Sujet

  def name          ; @name           ||= get(:name)          end
  def count         ; @count          ||= get(:count).to_i    end
  def last_post_id  ; @last_post_id   ||= get(:last_post_id)  end
  def categories    ; @categories     ||= get(:categories) || Array::new end
  def creator_id    ; @creator_id     ||= get(:creator_id)    end

  def dispatch_data d = nil
    (d || @data).each { |k,v| instance_variable_set("@#{k}", v) }
  end


  def data4create
    @data4create ||= {
      creator_id:   user.id,
      name:         name,
      categories:   categories,
      count:        count,
      last_post_id: last_post_id
    }
  end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  def creator ; @creator ||= User::get(creator_id.to_i) end

end #/Sujet
end #/Forum
