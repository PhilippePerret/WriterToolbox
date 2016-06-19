# encoding: UTF-8

def sujet
  @sujet ||= site.objet
end

class Forum
  class Sujet

    # Destruction du sujet
    # En fait, on ne fait que mettre son premier bit à 1
    def destroy
      if user.grade < 8
        mon_vieux = user.femme? ? "ma vieille" : "mon vieux"
        error "Vous n'avez pas le grade suffisant pour détruire un sujet, #{mon_vieux}…"
      else
        his_name = "#{name}"
        destroy_posts
        Forum::table_sujets.delete(id)
        flash "Sujet “#{his_name}” détruit."
      end
      redirect_to :last_page
    end
    def destroy_posts
      ids = Forum::table_posts.select(colonnes:[], where:{sujet_id: id}).keys
      if ids.empty?
        list_ids = ids.join(',')
        where_clause = {where: "id IN (#{list_ids})"}
        Forum::table_posts.delete( where_clause )
        Forum::table_posts_content.delete( where_clause )
        Forum::table_posts_votes.delete( where_clause )
      end
    rescue Exception => e
      error e.message
    end
  end
end

sujet.destroy
