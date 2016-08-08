# encoding: UTF-8
=begin

  Méthode `la_page_a_...`

=end

def la_page_a_pour_titre titre
  expect(page).to have_tag('h1', text: /#{Regexp.escape titre}/)
  puts "La page a pour titre “#{titre}”" if verbose?
end
alias :la_page_a_le_titre :la_page_a_pour_titre
def la_page_napas_pour_titre titre
  expect(page).not_to have_tag('h1', text: /#{Regexp.escape titre}/)
  puts "La page n'a pas pour titre “#{titre}”" if verbose?
end

def la_page_a_pour_soustitre stitre
  expect(page).to have_tag('h2', text: /#{Regexp.escape stitre}/)
  puts "La page a pour sous-titre “#{stitre}”" if verbose?
end
alias :la_page_a_le_soustitre :la_page_a_pour_soustitre
def la_page_napas_pour_soustitre stitre
  expect(page).not_to have_tag('h2', text: /#{Regexp.escape stitre}/)
  puts "La page n'a pas pour sous-titre “#{stitre}”" if verbose?
end

def la_page_affiche texte, options = nil
  expect(page).to have_content(texte)
  puts "La page affiche le texte “#{texte}”." if verbose?
end

def la_page_n_affiche_pas texte, options = nil
  expect(page).not_to have_content(texte)
  puts "La page affiche le texte “#{texte}”." if verbose?
end

def la_page_a_le_lien titre, options = nil
  options ||= Hash.new
  options.merge!(text: /#{Regexp.escape titre}/)
  expect(page).to have_tag('a', options)
  puts "La page a le lien “#{titre}”" if verbose?
end
def la_page_napas_le_lien titre, options = nil
  options ||= Hash.new
  options.merge!(text: /#{Regexp.escape titre}/)
  expect(page).not_to have_tag('a', options)
  puts "La page n'a pas le lien “#{titre}”" if verbose?
end

# +options+ peut définir :in, l'élément (formulaire) dans lequel
# se trouve l'objet
def la_page_a_une_liste ul_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: ul_id)
  expect(page).to have_tag("#{options[:in]} select", options)
  puts "La page a une liste UL##{ul_id}" if verbose?
end

def la_page_a_le_message mess, options = nil
  options ||= Hash.new
  options.merge!(text: /#{Regexp.escape mess}/)
  expect(page).to have_tag('div#flash div.notice', options)
  puts "La page affiche le message flash “#{mess}”." if verbose?
end

def la_page_a_l_erreur err, options = nil
  options ||= Hash.new
  options.merge!(text: /#{Regexp.escape err}/)
  expect(page).to have_tag('div#flash div.error', options)
  puts "La page affiche le message d'erreur flash “#{err}”." if verbose?
end

def la_page_a_le_formulaire form_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: form_id)
  expect(page).to have_tag('form', options)
  puts "La page contient le formulaire ##{form_id}." if verbose?
end
def la_page_napas_le_formulaire form_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: form_id)
  expect(page).not_to have_tag('form', options)
  puts "La page ne contient pas le formulaire ##{form_id}." if verbose?
end

def la_page_a_le_menu select_id, options = nil
  options ||= Hash.new
  options[:with] ||= Hash.new
  options[:with].merge!(id: select_id)
  expect(page).to have_tag("#{options[:in]} select".strip, options)
  puts "La page possède le menu ##{select_id}." if verbose?
end
def la_page_napas_le_menu select_id
  expect(page).not_to have_tag("select##{select_id}")
  puts "La page ne possède pas le menu ##{select_id}." if verbose?
end
