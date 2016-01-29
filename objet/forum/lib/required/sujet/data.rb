# encoding: UTF-8
class Forum
class Sujet

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def name          ; @name           ||= get(:name)          end
  def name= valeur  ; @name = valeur end
  def categories    ; @categories     ||= get(:categories) || Array::new end
  def creator_id    ; @creator_id     ||= get(:creator_id)    end
  # Dans autres tables
  def count         ; @count          ||= get_count           end
  def last_post_id  ; @last_post_id   ||= get_last_post_id    end
  def views         ; @views          ||= get_views           end


  def dispatch_data d = nil
    (d || @data).each { |k,v| instance_variable_set("@#{k}", v) }
  end


  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  def creator ; @creator ||= User::get(creator_id.to_i) end

  def data_type
    @data_type ||= TYPES[type_s]
  end

  private
    def get_count
      data_sujets_posts[:count]
    end
    def get_last_post_id
      data_sujets_posts[:last_post_id]
    end
    def get_views
      data_sujets_posts[:views]
    end
    def data_sujets_posts
      @data_sujets_posts ||= Forum::table_sujets_posts.get(id)
    end

end #/Sujet
end #/Forum
