# encoding: UTF-8
class SiteHtml
class TestSuite
class Form

  # Les méthodes propres aux routes (dès que l'objet-case
  # doit interagir avec la page)
  include ModuleRouteMethods


  def exist?
    exist(evaluate: false)
  end
  def not_exist
    exist(inverse: true)
  end
  # Produit un succès si le formulaire existe et qu'il contient
  # (intuitivement) les données définies. Produit une failure
  # dans le cas contraire.
  def exist options=nil
    opts = options || Hash::new
    responds # La page doit exister
    [:id, :name, :action].each do |k|
      opts.merge!(k => data_form[k]) if data_form.has_key?(k)
    end
    has_tag("form", opts, opts[:inverse]==true)
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
  #
  def fill_and_submit other_data = nil

    # Une copie des données originales transmises, pour
    # ne pas les modifier ici.
    this_data = data_form.dup

    # Modification optionnelle des données transmises
    # lors de l'instanciation
    unless other_data.nil?
      # Il faut merger les données de façon intelligente.
      # Par exemple, si other_data = {pseudo: "nouveau pseudo"} alors
      # la méthode commencera par rechercher si un champ :pseudo est
      # défini et s'il le trouve il mettre sa propriété :value à la
      # valeur définie
      other_data.each do |k, v|
        if this_data[:fields].has_key?(k)
          this_data[:fields][k][:value] = v
        else
          this_data.merge!(k => v)
        end
      end
    end

    # Préparation des données (:data) dont curl aura besoin
    # pour simuler la soumission du formulaire
    data_req = Hash::new
    this_data[:fields].each do |field_id, field_data|
      next unless field_data.has_key?(:name)
      data_req.merge! field_data[:name] => field_data[:value]
    end

    # On peut instancier la requête et l'exécuter
    req_curl = SiteHtml::TestSuite::Request::CURL::new(self, {form: true, data: data_req})
    req_curl.execute

  end


end #/Form
end #/TestSuite
end #/SiteHtml
