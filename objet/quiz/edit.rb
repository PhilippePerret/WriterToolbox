# encoding: UTF-8
=begin

  Module pour éditer le quiz

=end

# Exclusivement réservé à l'administration
raise_unless_admin

# Il faut surclasser la méthode `quiz` pour qu'elle ne cherche pas
# le quiz courant. Soit edit est appelé avec un id et on édite ce
# questionnaire, soit c'est un nouveau questionnaire
def quiz
  ::Quiz.suffix_base != nil || raise('Il faut impérativement spécifier le suffixe de la base, pour éditer ou créer un questionnaire.')
  if site.route.objet_id.nil?
    # => Nouveau quiz
    ::Quiz.new(nil)
  else
    ::Quiz.new(site.route.objet_id)
  end
end
