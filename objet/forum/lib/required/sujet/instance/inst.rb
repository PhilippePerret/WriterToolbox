# encoding: UTF-8
class Forum
  class Sujet

    include MethodesMySQL

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
      @id = Forum.table_sujets.insert( data4create.merge(created_at: NOW) )
      mail_to_admin
    end

    def mail_to_admin
      data_mail = {
        subject:  'Nouveau sujet sur le forum',
        formated:  true,
        message: <<-HTML
        <p>Phil</p>,
        <p>Un nouveau sujet forum est à valider.</p>
        <table>
          <tr><td>ID</td><td>#{id}</td></tr>
          <tr><td>Titre</td><td>#{titre}</td></tr>
          <tr><td>Créateur</td><td>#{user.pseudo} (##{user.id})</td></tr>
        </table>
        HTML
      }
      site.send_mail_to_admin data_mail
    end

    def data4create
      @data4create ||= {
        creator_id:   user.id,
        titre:        titre,
        categorie:    categorie,
        options:      "#{bit_validation}#{type_s}",
        last_post_id:   nil,
        count:          0,
        views:          0,
        updated_at:   NOW
      }
    end

    def incremente_vues
      @views = views + 1
      Forum.table_sujets.update( id, { views: @views, updated_at: NOW } )
    end

    # Raccourci à la table contenant les sujets
    def table
      @table ||= Forum.table_sujets
    end

  end

end
