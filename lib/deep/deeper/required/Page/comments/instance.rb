# encoding: UTF-8
class Page
  class Comments

    include MethodesMySQL

    # Toutes les données envoyées
    # Cette donnée est importante car elle sert notamment à la
    # création du commentaire
    attr_reader :data

    attr_reader :id, :pseudo, :user_id
    attr_reader :route, :comment, :date
    attr_reader :votes_up, :votes_down
    attr_reader :created_at, :updated_at
    # Les propriétés qui peuvent être appelées sans charger toutes
    # les données et en instanciant avec seulement l'identifiant du
    # commentaire (validation par exemple)
    def options   ; @options ||= get(:options)  end

    # On peut soit instancier le commentaire avec toutes ses
    # données, soit avec son identifiant Fixnum
    def initialize hdata
      case hdata
      when Hash
        @data = hdata
        hdata.each{|k, v| instance_variable_set("@#{k}", v)}
      when Fixnum
        @id = hdata
      end
    end

    def valided?
      @is_valided ||= options[0].to_i == 1
    end

    def as_li
      (
        div_infos +
        div_commentaire +
        div_boutons
      ).in_li(id: li_id, class: 'pcomment')
    end
    def li_id; @li_id ||= "li_pcomment-#{id}" end


    def div_infos
      (
      span_date +
      span_numero +
      span_auteur
      ).in_div(class: 'infos')
    end
    def div_commentaire
      comment.in_div(class: 'comment')
    end
    def div_boutons
      bs = String.new
      bs << bouton_vote_up
      bs << ' | '.in_span
      bs << bouton_vote_down
      if user.admin?
        bs << bouton_detruire
        valided? || bs << bouton_valider
      end
      bs.in_div(class: 'boutons btns')
    end


    def span_date
      created_at.as_human_date(true, true, nil, 'à').in_span(class: 'date')
    end
    def span_auteur
      pseudo.in_span(class: 'auteur')
    end
    def span_numero
      user.admin? || (return '')
      "##{id}".in_span(class: 'id')
    end

    def bouton_vote_up
      (
        '+1 (' + votes_up.to_s.in_span(class: 'votesup') + ')'
      ).in_a
    end
    def bouton_vote_down
      (
        '-1 (' + votes_down.to_s.in_span(class: 'votesdown') + ')'
      ).in_a
    end
    def bouton_detruire
      'détruire'.in_a(class: 'warning tiny btn', href: "page_comments/#{id}/list?in=site&action=destroy")
    end
    def bouton_valider
      'valider'.in_a(class: 'btn tiny', href: "page_comments/#{id}/list?in=site&action=valider")
    end

    def table
      @table ||= self.class.table
    end

  end #/Comments
end #/Page
