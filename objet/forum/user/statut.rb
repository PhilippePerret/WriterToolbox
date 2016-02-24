# encoding: UTF-8
=begin
=end
class User
  class << self

    # Liste des users comme liste UL pour les grades
    def as_ul
      User::as_array.collect do |iuser|
        iuser.as_li
      end.join.in_ul(class:'tdm',id:'users') +
      menu_gardes_mobile
    end

    # Un menu-select mobile des grades, pour le modifier chez
    # un user.
    def menu_gardes_mobile
      GRADES.in_select(id: "menu_grades", onchange:"$.proxy(User,'on_change_grade', this)()")
    end

  end #/ << self

  
  # Pour la gestion du grade.
  # La méthode surclasse toute méthode de même nom qui a pu
  # être définie
  def as_li
    (
      pseudo.in_span(class:'pseudo') +
      created_at.as_human_date.in_span(class:'date') +
      container_grade.in_span(class:'grade', id: "span_grade-#{id}")
    ).in_li(class:'user')
  end

  def container_grade
    grade_humain.in_a(onclick:"$.proxy(User,'on_click_grade', this)()", 'data-user' => id.to_s, 'data-grade' => grade)
  end

end
