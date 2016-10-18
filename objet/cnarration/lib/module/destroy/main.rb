# encoding: UTF-8
class Cnarration
class Page

  def destroy
    if destruction_confirmed?
      # === Procéder ===
      proceed_destruction
    else
      # === Pour la confirmation ===
      preparer_confirmation
    end
  end


  def destruction_confirmed?
    param(:confirmation_destruction_page) == 'on'
  end

  # = main =
  #
  # Méthode principale qui prépare le message de confirmation de la
  # destruction en disant ce qui va être supprimé.
  #
  # Note : pour le moment, on empêche de supprimer une page qui
  # appartient à une table des matières. Si c'est le cas, on propose
  # de la sortir de cette table des matières.
  #
  def preparer_confirmation
    livre_id == nil || begin
      flash 'La page appartient à une table des matières. Par mesure de sécurité, il faut la sortir de cette table des matières avant de pouvoir procéder à sa destruction.'
      return
    end

    flash "La page peut être détruite."

    if page?

    end

  end

  # = main =
  #
  # Méthode qui se charge de la destruction proprement dite
  #
  def proceed_destruction

  end

end #/Page
end #/Cnarration
