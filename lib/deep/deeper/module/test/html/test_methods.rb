# encoding: UTF-8
=begin

SiteHtml::Test::Html

Pour le traitement des codes Html

=end
class SiteHtml
class TestSuite
class HTML

  def has_message mess, options = nil, inverse = false
    options ||= Hash::new

    ok = has_tag?("div#flash div.notice", options.merge!(text: mess))

    # Message supplémentaire indiquant les messages
    # flash affichés dans la page
    mess_sup = ok ? "" : messages_flash_as_human(mess)

    # # Pour débugger
    # if !ok then
    #   debug "\n\n\n"+("-"*80)+"\n\n\n"
    #   debug "PAGE QUI NE CONTIENT PAS LE MESSAGE #{mess}:\n\n\n"
    #   debug page.to_s.gsub(/</,'&lt;')
    #   debug "\n\n\n"+("-"*80)+"\n\n\n"
    # end

    message_strict = if options[:strict]
      "message"
    else
      "message ressemblant à"
    end

    unless options[:evaluate] === false
      SiteHtml::TestSuite::Case::new(
        tmethod,
        result:           ok,
        positif:          !inverse,
        on_success:       "La page affiche bien le #{message_strict} “#{mess}”.",
        on_success_not:   "La page n'affiche pas de #{message_strict} “#{mess}” (OK).",
        on_failure:       "La page devrait afficher un #{message_strict} “#{mess}” (#{mess_sup}).",
        on_failure_not:   "La page ne devrait pas afficher un #{message_strict} “#{mess}”."
      ).evaluate
    else
      return ok
    end
  end
  def has_message? mess, options = nil, inverse = false
    options ||= Hash::new
    options.merge!(evaluate: false)
    has_message(mess, options, inverse)
  end

  def has_error mess, options = nil, inverse = false
    options ||= Hash::new

    ok = has_tag?("div#flash div.error", options.merge!(text: mess))

    # Message supplémentaire indiquant les messages
    # flash affichés dans la page
    mess_sup = ok ? "" : messages_flash_as_human(mess)

    message_strict = if options[:strict]
      "message d'erreur"
    else
      "message d'erreur ressemblant à"
    end

    unless options[:evaluate] === false
      SiteHtml::TestSuite::Case::new(
        tmethod,
        result:           ok,
        positif:          !inverse,
        on_success:       "La page affiche bien le #{message_strict} “#{mess}”.",
        on_success_not:   "La page n'affiche pas un #{message_strict} “#{mess}” (OK).",
        on_failure:       "La page devrait afficher le #{message_strict} “#{mess}” (#{mess_sup}).",
        on_failure_not:   "La page ne devrait pas afficher un #{message_strict} “#{mess}”."
      ).evaluate
    else
      return ok
    end
  end

  def has_error? mess, options = nil, inverse = false
    options ||= Hash::new
    options.merge!(evaluate: false)
    has_error(mess, options, inverse)
  end

  # Retourne true si le code contient le div#flash qui
  # contient les messages de l'application RestSite
  def has_flash_tag?
    has_tag( 'div#flash', evaluate: false )
  end
  def has_flash_message?
    has_tag( 'div#flash div.notice', evaluate: false ) || has_tag( 'div#flash div.message', evaluate: false )
  end
  def has_flash_error?
    has_tag( 'div#flash div.error', evaluate: false )
  end


  def has_tag? tag, options=nil, inverse=false
    has_tag(tag, (options||{}).merge(evaluate: false), inverse)
  end
  # Message qui cherche tab avec les options
  # Produit une failure ou un succès, sauf si :evaluate est false
  # dans les options.
  def has_tag tag, options=nil, inverse=false
    debug "-> SiteHtml::TestSuite::Html#has_tag( tag=#{tag.inspect}, options=#{options.inspect}, inverse=#{inverse.inspect})"
    options ||= Hash::new

    tag_init = tag.freeze

    # On modifie +tag+ en fonction des données d'options
    # éventuelle
    {
      # Note : `pref`, ci-dessous, ne sert à rien
      id:     {pref:'#', value:"##{options[:id]}"},
      class:  {pref:'.', value:".#{options[:class]}"}
    }.each do |prop, dprop|
      tag += dprop[:value] if options.has_key?(prop) && options[prop]!=nil
    end

    # On compte le nombre de balises qui peuvent répondre
    # à tag
    # ok = page.css(tag).count >= ( options[:count] ||= 1 )
    ok = page.css(tag).count >= ( options[:count] ||= 1 )

    debug "OK Balise #{tag} trouvée : #{ok.inspect}"


    # Si +options+ définit :text; il faut chercher le texte
    # dans les balises remontées
    if ok && options.has_key?(:text) && options[:text] != nil
      ok = 0 < search_text_in_tag(tag, options[:text], options)
    end

    # Soit on crée une évaluation, soit on retourne simplement
    # le résultat (quand options[:evaluate] == false)
    unless options[:evaluate] === false
      SiteHtml::TestSuite::Case::new(
        tmethod,
        result:           ok,
        positif:          !inverse,
        on_success:       "La balise #{tag} existe dans la page.",
        on_success_not:   "La balise #{tag} n'existe pas dans la page (OK).",
        on_failure:       "La balise #{tag} devrait exister dans la page.",
        on_failure_not:   "La balise #{tag} ne devrait pas exister dans la page."
      ).evaluate
    else
      return ok
    end
  end

  # Cherche le texte +text+ dans les balises définies par
  # +tag+ avec les options +options+ et retourne le nombre
  # de résultats trouvés.
  #
  # +text+        {String|RegExp} Le texte à rechercher
  #
  # +options+
  #   :several    Mettre à true pour chercher le texte plusieurs
  #               seule fois (false par défaut)
  #   :strict     Si true, recherche le texte strictement dans la
  #               balise (false par défaut)
  #
  # Retourne le nombre d'occurences trouvés (noter qu'il peut).
  # y en avoir plusieurs par balise.
  def search_text_in_tag tag, text, options = nil
    options ||= Hash::new

    # Le texte à trouver
    unless text.instance_of?(Regexp)
      text = if options[:strict]
        /^#{text}$/o
      else
        /#{text}/oi
      end
    end

    nombre_found = 0
    page.css(tag).each do |tested|
      if 0 < (nb = tested.text.scan(text).count)
        nombre_found += nb
        return nb unless options[:several] == true
      end
    end
    return nombre_found
  end

  def has_not_tag tag, options = nil
    has_tag tag, options, true
  end

  # Retourne TRUE si le titre est trouvé
  def has_title? titre, niveau=nil, options=nil, inverse=false
    options ||= Hash::new
    options.merge!(evaluate: false)
    has_title(titre, niveau, options, inverse)
  end
  def has_not_title titre, niveau = nil, options = nil
    has_title titre, niveau, options, true
  end
  # TEST-CASE
  def has_title titre, niveau = nil, options = nil, inverse = false
    # page.css("h#{niveau}").each do |tested|
    #   debug "tested : #{tested.text}"
    # end
    options ||= Hash::new

    # Faut-il prendre exactement le titre
    unless titre.instance_of?(RegExp)
      titre = if options[:strict]
        /#{Regexp::escape titre}/oi
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
      tmethod,
      result:           found == true,
      positif:          !inverse,
      on_success:       "Le titre #{tag} “#{titre_init}” existe dans la page.",
      on_success_not:   "Le titre #{tag} “#{titre_init}” n'existe pas dans la page (OK).",
      on_failure:       "Le titre #{tag} “#{titre_init}” devrait exister dans la page.",
      on_failure_not:   "Le titre #{tag} “#{titre_init}” ne devrait pas exister dans la page."
    ).evaluate
  end


end #/Html
end #/TestSuite
end #/SiteHtml
