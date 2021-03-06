# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def give_balise_of_scenodico mot_ref
    site.require_objet 'scenodico'
    res = Scenodico::table_mots.select(where:"mot LIKE '%#{mot_ref}%'", nocase: true, colonnes:[:mot]).values
    if res.empty?
      [nil, "Aucun mot n'a été trouvé correspondant à `#{mot_ref}`."]
    else
      balises = res.collect do |hmot|
        # Note : Il faut remplacer les apostrophes simples car le texte
        # sera mis dans un code entre apostrophes simples.
        {value: "MOT[#{hmot[:id]}|#{hmot[:mot].downcase.gsub(/\'/, '’')}]"}
      end
      [balises, "Nombre de mots trouvés : #{balises.count}"]
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
