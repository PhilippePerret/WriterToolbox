# encoding: UTF-8
class Forum
  class Sujet

    include MethodesObjetsBdD

    # ---------------------------------------------------------------------
    #   Instance Forum::Sujet
    # ---------------------------------------------------------------------
    attr_reader   :id

    def initialize id = nil
      @id = id.to_i_inn
    end

    def bind; binding() end

    # Créer le sujet
    def create
      @id = Forum::table_sujets.insert( data4create.merge(created_at: NOW) )
      Forum::table_sujets_posts.insert( dataposts4create )
    end

    def data4create
      @data4create ||= {
        creator_id:   user.id,
        name:         name,
        categories:   categories,
        options:      "#{bit_validation}#{type_s}",
        updated_at:   NOW
      }
    end
    def dataposts4create
      {
        id:             id,
        last_post_id:   nil,
        count:          0,
        views:          0,
        updated_at:     NOW
      }
    end

    def incremente_vues
      @views = views + 1
      Forum::table_sujets_posts.update( id, { views:@views, updated_at:NOW } )
    end

    # Raccourci à la table contenant les sujets
    def table
      @table ||= Forum::table_sujets
    end

  end

end
