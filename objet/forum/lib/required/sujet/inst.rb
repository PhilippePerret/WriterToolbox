# encoding: UTF-8
class Forum
  class Sujet
    # ---------------------------------------------------------------------
    #   Instance Forum::Sujet
    # ---------------------------------------------------------------------
    attr_reader   :id
    attr_accessor :name
    attr_reader   :last_message
    attr_reader   :count
    attr_reader   :options
    attr_reader   :creator_id
    attr_reader   :created_at

    def initialize id = nil, data = nil
      @id   = id.to_i_inn
      @data = data
      @data = table_sujets.get(@id) if data.nil? && @id != nil
      dispatch_data unless @data.nil?
    end

    def dispatch_data
      @data.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    def categories
      @categories ||= Array::new
    end

    def all_data
      @all_data ||= {
        creator_id:   user.id,
        name:         name,
        categories:   categories.join(','),
        count:        count,
        last_message: last_message
      }
    end


    def bind; binding() end

    def set hdata
      table_sujets.update( id, hdata )
      hdata.each { |k,v| instance_variable_set("@#{k}", v)}
    end
    def get key
      table_sujets.select(where:{id:id}, colonnes:[key]).values.first[key]
    end
    
    # Sauver toutes les données du sujet
    def save
      all_data.merge!(updated_at: Time.now.to_i)
      if @id.nil?
        # => création
        all_data.merge!(created_at: Time.now.to_i)
        @id = self.class.table_sujets.insert(all_data)
      else
        # => édition
        self.class.table_sujets.set(id, all_data)
      end
    end

    # Raccourci à la table contenant les sujets
    def table_sujets
      @table_sujets ||= self.class::table_sujets
    end

  end

end
