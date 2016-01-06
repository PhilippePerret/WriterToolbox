# encoding: UTF-8
class Forum

  def sujets
    @sujets ||= Sujet
  end

  class Sujet
    # ---------------------------------------------------------------------
    #   Class Forum::Sujet
    # ---------------------------------------------------------------------
    class << self

      # Méthode d'helper retournant la liste des sujets dans des
      # LI
      def as_list
        all.collect { |sid, sujet| sujet.as_li }.join('')
      end

    end # << self

    # ---------------------------------------------------------------------
    #   Instances Forum::Sujet (un sujet en particulier)
    # ---------------------------------------------------------------------

    def as_li
      # return "#{id}"
      (as_titre_in_listing_messages + div_infos_last_message + div_tools).in_li(class:'topic')
    end

    def as_titre_in_listing_messages
      "#{name}".in_div(class:'topic_titre')
    end
    def div_infos_last_message
      (
        created_at.as_human_date(false).in_span(class:'date')+
        info_nombre_messages      +
        info_last_message
      ).in_div(class: 'topic_infos')
    end
    def info_last_message
      mess = case last_message
      when nil then "--- aucun ---"
      else
        Forum::Message::new(last_message).titre
      end
      "Dernier message : #{mess}".in_span(class:'last_message')
    end
    def info_nombre_messages
      "Tot: #{count || 0}".in_span(class:'count')
    end

    # Les outils pour le sujet, avec des outils différents
    # en fonction du niveau de l'user
    def div_tools
      (
      "Détruire ce sujet".in_a(href:"sujet/#{id}/destroy?in=forum", onclick:"if(confirm('Veux-tu vraiment détruire ce sujet ?')){return true}else{return false}") +
      '<br />' +
      "Lire ce sujet".in_a(href:"sujet/#{id}/read?in=forum")
      ).in_div(class:'hidetools')
    end

  end
end
