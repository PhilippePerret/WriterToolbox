# encoding: UTF-8
=begin

  Méthode `la_page_a_...`

=end
class TestTag
  include Capybara::DSL

  attr_reader :jid
  def initialize jid
    @jid = jid
  end
  def contient_la_balise tagname, args = nil
    args ||= Hash.new
    args.key?(:id)    && tagname << "##{args.delete(:id)}"
    args.key?(:class) && tagname << ".#{args.delete(:class)}"
    mess_success = args.delete(:success) || "La balise contient #{tagname}"
    mess_failure = args.delete(:failure) || "La balise devrait contenir #{tagname}"
    if page.find(jid).has_css?(tagname, args)
      success mess_success
    else
      raise mess_failure
    end
  end
end

def la_balise jid
  TestTag.new jid
end

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
  visible = args.delete(:visible)
  if args.key? :text
    t = args.delete :text
    t.instance_of?(Regexp) || t = /#{Regexp.escape t}/i
    options.merge!( text: t )
  end
  options.merge!(success: args.delete(:success)) if args.key?(:success)
  options.merge!(in: args.delete(:in)) if args.key?(:in)
  options.merge!(with: args)
  visible.nil? || options.merge!(visible: visible)
  options
end


def la_page_a_pour_titre titre
  la_page_a_la_balise 'h1', text: titre, success: "La page a pour titre “#{titre}”."
end
alias :la_page_a_le_titre :la_page_a_pour_titre

def la_page_napas_pour_titre titre
  la_page_napas_la_balise 'h1', text: titre, success: "La page n'a pas pour titre “#{titre}”."
end

def la_page_a_pour_soustitre stitre
  la_page_a_la_balise 'h2', text: stitre, success: "La page a pour sous-titre “#{stitre}”."
end
alias :la_page_a_le_soustitre :la_page_a_pour_soustitre

def la_page_napas_pour_soustitre stitre
  la_page_napas_la_balise 'h2', text: stitre, success: "La page n'a pas pour sous-titre “#{stitre}”."
end

def la_page_affiche texte, options = nil
  options = options_from_args(options)
  mess_succ = options[:success] || "La page affiche le texte “#{texte}”."
  if options.key? :in
    within(options.delete(:in)){expect(page).to have_content(texte)}
  else
    expect(page).to have_content(texte)
  end
  success mess_succ
end

def la_page_naffiche_pas texte, options = nil
  options = options_from_args(options)
  mess_succ = options[:success] || "La page n'affiche pas le texte “#{texte}”."
  if options.key? :in
    within(options.delete(:in)){expect(page).not_to have_content(texte)}
  else
    expect(page).not_to have_content(texte)
  end
  success mess_succ
end

def la_page_a_le_lien titre, options = nil
  options = options_from_args(options)
  mess_succ = options[:success] || "La page a le lien “#{titre}”."
  options.merge!(text: titre)
  if options.key? :in
    within(options.delete(:in)){ expect(page).to have_tag('a', options) }
  else
    expect(page).to have_tag('a', options)
  end
  success mess_succ
end

def la_page_napas_le_lien titre, options = nil
  options = options_from_args(options)
  mess_succ = options[:success] || "La page n'a pas le lien “#{titre}”."
  options.merge!(text: titre)
  if options.key? :in
    within(options.delete(:in)){ expect(page).not_to have_tag('a', options) }
  else
    expect(page).not_to have_tag('a', options)
  end
  success mess_succ
end

def la_page_a_la_balise tagname, args = nil
  options = options_from_args(args)
  mess_succ = options[:success] || "La page possède la balise #{tagname} (arguments : #{options.inspect})"
  if options.key? :in
    within(options.delete(:in)){ expect(page).to have_tag(tagname, options) }
  else
    expect(page).to have_tag(tagname, options)
  end
  success mess_succ
end
def la_page_napas_la_balise tagname, args = nil
  options = options_from_args(args)
  mess_succ = options[:success] || "La page ne possède pas la balise #{tagname} (arguments : #{options.inspect})."
  if options.key? :in
    within(options.delete(:in)){ expect(page).not_to have_tag(tagname, options) }
  else
    expect(page).not_to have_tag(tagname, options)
  end
  success mess_succ
end
# +options+ peut définir :in, l'élément (formulaire) dans lequel
# se trouve l'objet
def la_page_a_la_liste ul_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page contient la liste UL##{ul_id}."
  la_page_a_la_balise 'ul', args.merge(id: ul_id)
end
alias :la_page_a_une_liste :la_page_a_la_liste
def la_page_napas_la_liste ul_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page ne contient pas la liste UL##{ul_id}."
  la_page_napas_la_balise 'ul', args.merge(id: ul_id)
end

def la_page_a_le_menu select_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page contient le menu select##{ul_id}."
  la_page_a_la_balise 'select', args.merge(id: select_id)
end
def la_page_napas_le_menu select_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page ne contient pas le menu select##{ul_id}."
  la_page_napas_la_balise 'select', args.merge(id: select_id)
end


def la_page_a_la_section section_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page contient la section ##{section_id}."
  la_page_a_la_balise 'section', args.merge(id: section_id)
end
def la_page_napas_la_section section_id, args = nil
  args ||= Hash.new
  args[:success] ||= "La page ne contient pas la section ##{section_id}."
  la_page_napas_la_balise 'section', args.merge(id: section_id)
end


def la_page_a_le_message mess, options = nil
  options ||= Hash.new
  mess_succ = options[:success] || "La page affiche le message flash “#{mess}”."
  options.merge!(text: /#{Regexp.escape mess}/)
  tr = 0; while (tr += 1) < 20
    page.has_css?('div#flash div.notice', options) ? break : (sleep 1)
  end
  expect(page).to have_tag('div#flash div.notice', options)
  success mess_succ
end
def la_page_napas_le_message mess, options = nil
  options ||= Hash.new
  mess_succ = options[:success] || "La page n'affiche pas le message flash “#{mess}”."
  options.merge!(text: /#{Regexp.escape mess}/)
  expect(page).not_to have_tag('div#flash div.notice', options)
  success mess_succ
end

#
#
# Note : pour ce test, on attend quelques secondes si c'est en
# ajax.
# Note : le message d'erreur peut se trouver soit dans le flash soit
# dans un div de class warning.
def la_page_a_l_erreur err, options = nil
  options ||= Hash.new
  ajax = options[:ajax] == true
  options.merge!(text: /#{Regexp.escape err}/)
  hasflash, haserror = nil, nil
  tr = 0; while (tr += 1) < 20
    hasflash = page.has_css?('div#flash div.error', options)
    haserror = page.has_css?('div.warning', options)
    ( hasflash || haserror )? break : (sleep 1)
  end
  if hasflash
    expect(page).to have_tag('div#flash div.error', options)
    success "La page affiche le message d'erreur flash “#{err}”."
  else
    expect(page).to have_tag('div.warning', options)
    success "La page affiche le message warning “#{err}”."
  end
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

def la_page_a_l_erreur_fatale err, options = nil
  options ||= Hash.new
  ajax = options[:ajax] == true
  options.merge!(text: /#{Regexp.escape err}/)
  tr = 0; while (tr += 1) < 20
    page.has_css?('div#flash div.error', options) ? break : (sleep 0.5)
  end
  expect(page).to have_tag('div.fatal_error', options)
  success "La page affiche le message d'erreur fatale “#{err}”."
end

def la_page_napas_derreur_fatale
  if page.has_css?('div.fatal_error')
    idiv = 0; erreurs = Array.new
    o = page.find('div.fatal_error')
    raise "La page ne devrait pas avoir rencontré d'erreur, elle a rencontré l'erreur fatale : #{o.text}"
  else
    success "La page n'affiche pas d'erreur fatale."
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
