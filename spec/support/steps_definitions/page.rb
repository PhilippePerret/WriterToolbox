# encoding: UTF-8
=begin

  Méthode `la_page_a_...`

=end

# Pour traiter les arguments qui sont envoyés aux méthodes. Dans ces
# arguments, tous les attributs peuvent être mis ensemble (:text, :id, etc.)
# et cette méthode sépare d'un côté le :text et de l'autre met les attributs
# dans :with
#
# Paramètre spécial :in pour définir le within dans lequel on doit trouver
# l'élément.
#
def options_from_args args
  options ||= Hash.new
  args != nil || ( return options )
  options.merge!(text: /#{Regexp.escape args.delete(:text)}/) if args.key?(:text)
  options.merge!(in: args.delete(:in)) if args.key?(:in)
  options.merge!(with: args)
end


def la_page_a_pour_titre titre
  expect(page).to have_tag('h1', text: /#{Regexp.escape titre}/)
  success "La page a pour titre “#{titre}”" if verbose?
end
alias :la_page_a_le_titre :la_page_a_pour_titre

def la_page_napas_pour_titre titre
  expect(page).not_to have_tag('h1', text: /#{Regexp.escape titre}/)
  success "La page n'a pas pour titre “#{titre}”" if verbose?
end

def la_page_a_pour_soustitre stitre
  expect(page).to have_tag('h2', text: /#{Regexp.escape stitre}/)
  success "La page a pour sous-titre “#{stitre}”" if verbose?
end
alias :la_page_a_le_soustitre :la_page_a_pour_soustitre

def la_page_napas_pour_soustitre stitre
  expect(page).not_to have_tag('h2', text: /#{Regexp.escape stitre}/)
  success "La page n'a pas pour sous-titre “#{stitre}”" if verbose?
end

def la_page_affiche texte, options = nil
  options = options_from_args(options)
  if options.key? :in
    within(options.delete(:in)){expect(page).to have_content(texte)}
  else
    expect(page).to have_content(texte)
  end
  success "La page affiche le texte “#{texte}”." if verbose?
end

def la_page_n_affiche_pas texte, options = nil
  options = options_from_args(options)
  if options.key? :in
    within(options.delete(:in)){expect(page).not_to have_content(texte)}
  else
    expect(page).not_to have_content(texte)
  end
  success "La page affiche le texte “#{texte}”."
end

def la_page_a_le_lien titre, options = nil
  options = options_from_args(options)
  options.merge!(text: titre)
  if options.key? :in
    within(options.delete(:in)){ expect(page).to have_tag('a', options) }
  else
    expect(page).to have_tag('a', options)
  end
  success "La page a le lien “#{titre}”"
end

def la_page_napas_le_lien titre, options = nil
  puts '-> la_page_napas_le_lien'
  options = options_from_args(options)
  options.merge!(text: titre)
  puts "options : #{options.inspect}"
  if options.key? :in
    puts "within #{options[:in]}"
    within(options.delete(:in)){ expect(page).not_to have_tag('a', options) }
  else
    expect(page).not_to have_tag('a', options)
  end
  success "La page n'a pas le lien “#{titre}”"
end

def la_page_a_la_balise tagname, args = nil
  options = options_from_args(args)
  if options.key? :in
    within(options.delete(:in)){ expect(page).to have_tag(tagname, options) }
  else
    expect(page).to have_tag(tagname, options)
  end
  success "La page possède la balise #{tagname} (arguments : #{options.inspect})"
end
def la_page_napas_la_balise tagname, args = nil
  options = options_from_args(args)
  if options.key? :in
    within(options.delete(:in)){ expect(page).not_to have_tag(tagname, options) }
  else
    expect(page).not_to have_tag(tagname, options)
  end
  success "La page ne possède pas la balise #{tagname} (arguments : #{options.inspect})"
end
# +options+ peut définir :in, l'élément (formulaire) dans lequel
# se trouve l'objet
def la_page_a_une_liste ul_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: ul_id)
  expect(page).to have_tag("#{options[:in]} select", options)
  success "La page a une liste UL##{ul_id}" if verbose?
end

def la_page_a_le_message mess, options = nil
  options ||= Hash.new
  options.merge!(text: /#{Regexp.escape mess}/)
  expect(page).to have_tag('div#flash div.notice', options)
  success "La page affiche le message flash “#{mess}”."
end

def la_page_a_l_erreur err, options = nil
  options ||= Hash.new
  options.merge!(text: /#{Regexp.escape err}/)
  expect(page).to have_tag('div#flash div.error', options)
  success "La page affiche le message d'erreur flash “#{err}”."
end
def la_page_napas_derreur
  if page.has_css?('div#flash div.error')
    idiv = 0; erreurs = Array.new
    while page.has_css?("div#flash div.error:nth-child(#{idiv += 1})")
      o = page.find("div#flash div.error:nth-child(#{idiv})")
      erreurs << "“#{o.text}”"
    end
    erreurs = erreurs.pretty_join
    raise "La page ne devrait pas contenir d'erreur, elle contient les messages : #{erreurs}"
  else
    success "La page n’affiche pas de message d'erreur."
  end
end

def la_page_a_le_formulaire form_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: form_id)
  expect(page).to have_tag('form', options)
  success "La page contient le formulaire ##{form_id}."
end
def la_page_napas_le_formulaire form_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: form_id)
  expect(page).not_to have_tag('form', options)
  success "La page ne contient pas le formulaire ##{form_id}."
end

def la_page_a_le_menu select_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: select_id)
  expect(page).to have_tag("#{options[:in]} select".strip, options)
  puts "La page possède le menu ##{select_id}."
end
def la_page_napas_le_menu select_id
  expect(page).not_to have_tag("select##{select_id}")
  success "La page ne possède pas le menu ##{select_id}."
end
