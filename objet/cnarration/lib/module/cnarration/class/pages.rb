# encoding: UTF-8
=begin
Extension pour la gestion des pages de la collection narration
en temps qu'ensemble continu et homogène.
=end
class Cnarration
class << self

  # Retourne une donnée en fonction de params[:as] qui est
  # Array de data par défaut et retourne donc toutes les pages
  # dans l'ordre de création sous forme de array ou chaque élément
  # et un hash de donnée
  # param[:as]
  #   :array_data       Array de data (défaut)
  #   :array_instances  Array d'instances Cnarration::Page
  #   :hash_data        Hash de data (clé = id de la page)
  #   :hash_instances   Même chose avec des instances Cnarration::Page
  #   :ul               Comme une liste HTML dans UL
  #   :select           Comme un menu select avec en titre le titre de
  #                     la page et en valeur l'id
  #
  # Ces pages peuvent être filtrées par le paramètre params[:where]
  # ce paramètre sera mis telle quelle dans le where du select pour
  # trouver les pages.
  def pages params = nil
    params ||= Hash::new
    params[:as] ||= :array_data
    params[:where] ||= "options LIKE '1%'"

    if [:array_instances, :hash_instances].include? params[:as]
      params[:colonnes] ||= []
    elsif params[:as] == :ul
      params[:colonnes] = [:titre]
    end

    data_requete = Hash::new
    data_requete.merge!( where: params.delete(:where) )
    data_requete.merge!( colonnes:params.delete(:colonnes) ) unless params[:colonnes].nil?
    # Si un ordre a été défini, il faut le prendre en compte
    data_requete.merge!(order: params.delete(:order)) unless params[:order].nil?

    pgs = table_pages.select(data_requete)

    case params[:as]
    when :hash_data       then pgs
    when :array_data      then pgs.values
    when :array_instances then pgs.keys.collect{ |pid| Page::new(pid) }
    when :hash_instances
      h = Hash::new
      pgs.keys.each { |pid| h.merge!( pid => Page::new(pid) ) }
      h
    when :ul
      # Une liste UL doit être retournée
      pgs.values.collect do |hpage|
        hpage[:titre].in_option(value: hpage[:id])
      end.in_ul(class:'tdm')
    end
  end

end #/<< self
end #/ Cnarration
