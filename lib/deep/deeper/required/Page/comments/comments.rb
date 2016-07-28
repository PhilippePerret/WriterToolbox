# encoding: UTF-8
=begin

  Les commentaires en tant que liste

=end
class Page
class Comments
  class << self

    # = main =
    #
    # Retourne le code Html UL pour la liste des commentaires, ou
    # simplement le commentaire "Aucun commentaire pour le moment."
    def ul_current_route_comments
      allcoms = current_route_comments
      if allcoms.empty?
        'Cette page n’a fait l’objet d’aucun commentaire pour le moment.'.in_div(id: 'div_no_page_comment')
      else
        current_route_comments.collect do |comment|
          comment.as_li
        end.join.in_ul(id: 'ul_page_comments')
      end
    end

    # Les commentaires de la route courante
    # Retourne une liste Array d'instance Page::Comments de ces
    # commentaires.
    #
    # Noter que pour un visiteur non administrateur, on ne prend
    # que les commentaires qui ont été validés.
    #
    def current_route_comments
      whereclause = "route = '#{site.current_route.route}'"
      user.admin? || whereclause += " AND SUBSTRING(options,1,1) = '1'"
      drequest = {
        where: whereclause,
        order: 'created_at DESC'
      }
      table.select(drequest).collect do |hcomment|
        new(hcomment)
      end
    end

    def table
      @table ||= site.dbm_table(:cold, 'page_comments')
    end

  end #/<< self
  # ---------------------------------------------------------------------
  #   INSTANCES
  #
  # ---------------------------------------------------------------------

  # Toutes les données envoyées
  # Cette donnée est importante car elle sert notamment à la
  # création du commentaire
  attr_reader :data

  attr_reader :id, :pseudo, :user_id
  attr_reader :route, :comment, :date
  attr_reader :votes_up, :votes_down
  attr_reader :options
  attr_reader :created_at, :updated_at

  def initialize hdata
    @data = hdata
    hdata.each{|k, v| instance_variable_set("@#{k}", v)}
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
      bs << bouton_valider
    end
    bs.in_div(class: 'boutons btns')
  end


  def span_date
    created_at.as_human_date(true, true, nil, 'à').in_span(class: 'date')
  end
  def span_auteur
    pseudo.in_span(class: 'auteur')
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
    'détruire'.in_a(class: 'warning tiny btn', href: "")
  end
  def bouton_valider
    'valider'.in_a(class: 'btn tiny', href: "")
  end
end #/Comments
end #/Page
