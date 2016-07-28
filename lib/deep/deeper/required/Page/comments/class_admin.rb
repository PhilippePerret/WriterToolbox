# encoding: UTF-8
class Page
class Comments
  class << self

    def valider_comment pcom_id
      user.admin? || raise
      flash "Commentaire validé."
      new(pcom_id).validate
    end
    def destroy_comment pcom_id
      user.admin? || raise
      if param(:confirm_destroy) == '1'
        table.delete(where:{ id: pcom_id })
        flash "Commantaire détruit."
      else
        # On fait un message pour confirmer la demande
        lien = "page_comments/#{pcom_id}/list?in=site&action=destroy&confirm_destroy=1"
        lien = 'Confirmation de la destruction'.in_a(href: lien, class: 'btn warning').in_div(class: 'air center')
        flash "Merci de confirmer la destruction du commentaire ##{pcom_id} : #{lien}"
      end
    end

  end #/<< self

  # Validation du message
  def validate
    opts = options.dup
    opts[0] = "1"
    set(options: opts)
  end

end #/Comments
end #/Page
