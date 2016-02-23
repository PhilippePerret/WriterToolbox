# encoding: UTF-8
class Forum
  class << self
    def new_topic
      new_topic_name  = param(:new_topic_name)
      creator_id      = user.id.freeze
      sujet = Sujet::new
      sujet.name = new_topic_name
      if sujet.save
        flash "Nouveau sujet “#{sujet.name}” créé."
      end
    rescue Exception => e
      error e.message
    ensure
      # Quoi qu'il se passe, il faut rediriger vers la liste des
      # sujets
      redirect_to 'sujet/list?in=forum'
    end
  end # << self Forum

  class Sujet
    # ---------------------------------------------------------------------
    #   Classe Forum::Sujet
    # ---------------------------------------------------------------------
    class << self
      def bind; binding() end

      def table_sujets
        @table_sujets ||= site.db.create_table_if_needed('forum', 'sujets')
      end
    end # << self
  end
end
