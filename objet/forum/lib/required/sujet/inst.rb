# encoding: UTF-8
class Forum
  class Sujet

    include MethodesObjetsBdD

    # ---------------------------------------------------------------------
    #   Instance Forum::Sujet
    # ---------------------------------------------------------------------
    attr_reader   :id

    def initialize id = nil, data = nil
      @id   = id.to_i_inn
      @data = data
      @data = table.get(@id) if data.nil? && @id != nil
      dispatch_data unless @data.nil?
    end

    def bind; binding() end

    # Créer le sujet
    def create
      @id = table.insert(data4create.merge(created_at: NOW))
    end

    # Sauver toutes les données du sujet
    def save
      table.update(id, all_data)
    end

    # Raccourci à la table contenant les sujets
    def table
      @table ||= Forum::table_sujets
    end

  end

end
