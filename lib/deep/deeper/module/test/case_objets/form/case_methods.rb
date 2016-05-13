# encoding: UTF-8
class SiteHtml
class TestSuite
class Form

  # Les méthodes propres aux routes (dès que l'objet-case
  # doit interagir avec la page)
  include ModuleRouteMethods


  # Produit un succès si le formulaire existe et qu'il contient
  # (intuitivement) les données définies. Produit une failure
  # dans le cas contraire.
  def exist
    opts = Hash::new
    responds # La page doit exister
    [:id, :name, :action].each do |k|
      opts.merge!(k => data_form[k]) if data_form.has_key?(k)
    end
    has_tag("form", opts)
  end

  # Remplit le formulaire avec les données spécifiées à l'instanciation
  # ou les nouvelles données transmises à la méthode.
  # Produit un succès si l'opération réussit, produit un échec dans le
  # cas contraire.
  #
  # Note : On utilise cUrl ici pour faire l'opération.
  #
  # +other_data+
  #     Redéfinition des données transmises
  #     Autres données possibles comme :
  #       :submit     Si true, le formulaire est soumis
  #
  def fill other_data = nil
    other_data ||= Hash::new
    soumettre = other_data.delete(:submit)
    dform     = data_form.merge(other_data)


  end


  def has_error err, options = nil

  end

  def has_message mess, options = nil

  end

end #/Form
end #/TestSuite
end #/SiteHtml
