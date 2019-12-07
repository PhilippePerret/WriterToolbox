# encoding: UTF-8
class ::Quiz

  def liens_admin
    (
      bouton_edit_quiz
    ).in_div(class: 'right small btns')
  end
  def bouton_edit_quiz
    '[éditer]'.in_a(href: "quiz/#{id}/edit")
  end

end
