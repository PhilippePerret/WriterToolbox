# encoding: UTF-8
class AnalyseBuild
class << self

  # Liste des films de l'analyste/admin courant
  def liste_films_current_user link_attrs = nil
    user_films_tmp.collect do |filmo|
      link_attrs.each do |k, v|
        link_attrs[k] = v % {id: filmo.id}
      end
      filmo.titre.in_a(link_attrs).in_li
    end.join.in_ul(class: 'ul_films')
  end

  # Liste des films des autres auteurs que l'analyste courant
  def liste_films_other_users attrs = nil
    other_user_films_tmp.collect do |filmo|
      analystes = filmo.analystes.collect{|u| u.pseudo}.pretty_join
      link_attrs.each do |k, v|
        link_attrs[k] = v % {id: filmo.id}
      end
      "#{filmo.titre} (#{analystes})".in_a(link_attrs).in_li
    end.join.in_ul(class: 'ul_films')
  end

end #/<< self
end #/AnalyseBuild
