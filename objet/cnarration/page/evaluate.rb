# encoding: UTF-8
class Cnarration
class Page

  # = main =
  #
  # Méthode principale qui sauve l'évaluation de la page
  # si elle a été donnée.
  def save_evaluation
    return error "Pour évaluer une page, vous devez être identifié." unless user.identified?
    return error "Vous avez déjà évalué cette page." if user_has_evaluated_page?
    Cnarration::table_evaluation.insert(data_evaluation)
    flash "Merci pour cet avis."
  end

  def user_has_evaluated_page?
    Cnarration::table_evaluation.count(where:"page_id = #{id} AND user_id = #{user.id}") > 0
  end

  def param_eval
    @param_eval ||= param(:evaluation)
  end

  def data_evaluation
    @data_evaluation ||= {
      user_id:    user.id,
      page_id:    ipage.id,
      clarte:     param_eval[:clarte].to_i,
      interet:    param_eval[:interet].to_i,
      comment:    commentaire_devaluation,
      created_at: NOW
    }
  end

  def commentaire_devaluation
    @commentaire_devaluation ||= begin
      c = param_eval[:comment].nil_if_empty
      c.gsub!(/<(.*?)>/,'')[0..500] unless c.nil?
      c
    end
  end

end # /Page
end # /Cnarration

def ipage
  @ipage ||= begin
    page_id.nil? ? nil : Cnarration::Page::get(page_id)
  end
end
def page_id
  @page_id ||= begin
    if param(:evaluation) != nil
      param(:evaluation)[:page_id].to_i_inn
    else
      nil
    end
  end
end

ipage.save_evaluation
redirect_to :last_route
