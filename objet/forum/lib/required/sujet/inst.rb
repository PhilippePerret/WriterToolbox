# encoding: UTF-8
class Forum
  class Sujet

    include MethodesObjetsBdD

    # ---------------------------------------------------------------------
    #   Instance Forum::Sujet
    # ---------------------------------------------------------------------
    attr_reader   :id
    attr_accessor :name
    attr_reader   :last_message
    attr_reader   :count
    attr_reader   :options
    attr_reader   :creator_id # ID du user créator du sujet
    attr_reader   :updated_at
    attr_reader   :created_at

    def initialize id = nil, data = nil
      @id   = id.to_i_inn
      @data = data
      @data = table.get(@id) if data.nil? && @id != nil
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

    # Créer le sujet
    def created
      @id = table.insert(data2save.merge(created_at: NOW))
    end

    # Sauver toutes les données du sujet
    def save
      table.update(id, all_data)
    end

    # Raccourci à la table contenant les sujets
    def table
      @table ||= self.class::table_sujets
    end

  end

end
