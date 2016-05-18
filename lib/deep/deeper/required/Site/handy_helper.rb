# encoding: UTF-8

# +path+ depuis le dossier ./view/img
def image path, options = nil
  options ||= Hash::new
  path = (site.folder_images + path).to_s
  path.in_image(options)
end

# Méthodes qui construisent notamment le titre du
# logo du site avec une première lettre qui se
# détache du reste (class span.first_letter_main_link)
# pour former le logo "BOA"
# On s'en sert aussi dans la marge gauche pour reprendre
# le visuel avec le mot "Outils"
def main_link( titre, uri = nil, options = nil )
  options ||= {}
  options.merge!(href: uri, class:'mainlink')
  as_main_link(titre).in_a(options)
end
def as_main_link titre
  dtitre = titre.split('')
  first_letter = dtitre.shift
  other_letters = dtitre.join('')
  "<span class='first_letter_main_link'>#{first_letter}</span>" +
  "<span class='other_letters_main_link'>#{other_letters}</span>"
end
