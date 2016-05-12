# encoding: UTF-8
=begin

SiteHtml::Test::Html

Pour le traitement des codes Html

=end
class SiteHtml
class TestSuite
class Html


  def has_title titre, niveau = nil, options = nil, inverse = false
    # page.css("h#{niveau}").each do |tested|
    #   debug "tested : #{tested.text}"
    # end
    options ||= Hash::new

    # Faut-il prendre exactement le titre
    unless options[:strict] || titre.instance_of?(RegExp)
      titre = if options[:strict]
        /#{Regexp::escape titre}/o
      else
        /^#{Regexp::escape titre}$/o
      end
    end
    niveaux = niveau ? [niveau] : (1..6)

    # On cherche le titre
    found = false
    niveaux.each do |niv|
      page.css("h#{niv}").each do |tested|
        if tested.text.match titre
          found == true
          break
        end
      end
    end

    SiteHtml::TestSuite::Case::new(
      result:           found == true,
      positif:          !inverse,
      on_success:       "Le titre #{tag} “#{titre_init}” existe dans la page.",
      on_success_not:   "Le titre #{tag} “#{titre_init}” n'existe pas dans la page (OK).",
      on_failure:       "Le titre #{tag} “#{titre_init}” devrait exister dans la page.",
      on_failure_not:   "Le titre #{tag} “#{titre_init}” ne devrait pas exister dans la page."
    ).evaluate
  end
  def has_not_title titre, niveau = nil, options = nil
    has_title titre, niveau, options, true
  end

  def has_tag tag, options, inverse = false
    debug "-> has_tag"
    options ||= Hash::new
    ok = page.css(tag).count >= ( options[:count] ||= 1 )
    SiteHtml::TestSuite::Case::new(
      result:           ok,
      positif:          !inverse,
      on_success:       "La balise #{tag} existe dans la page.",
      on_success_not:   "La balise #{tag} n'existe pas dans la page (OK).",
      on_failure:       "La balise #{tag} devrait exister dans la page.",
      on_failure_not:   "La balise #{tag} ne devrait pas exister dans la page."
    ).evaluate
  end

  def has_not_tag tag, options = nil
    has_tag tag, options, true
  end


end #/Html
end #/TestSuite
end #/SiteHtml
