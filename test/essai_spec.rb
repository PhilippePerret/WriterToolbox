# encoding: UTF-8

# Option -o "un/fichier"
# Pour que la page retournée soit enregistrée dans un fichier
# plutôt que retournée
# Note : -O pour l'enregistrer dans le même nom de page

# Option -I ou --head
# Retourne seulement l'entête (HEADER)

# Option -f
# On peut ajouter `-f` pour que la page d'erreur ne soit
# pas retournée en cas d'erreur (code 22)

# Option -F
# Pour simuler la soumission d'un formulaire
# curl -F "name=\"Son nom\";prenom='Prénom'" example.com
# Fichier uploadé :
# curl -F "web=@index.html;type=text/html" example.com

req = 'curl -I "http://www.laboiteaoutilsdelauteur.fr/bad/one.htm"'

# res = `curl -I "http://www.laboiteaoutilsdelauteur.fr/bad/one.htm"`

# Il faudrait pouvoir faire un truc comme :
test "La page bad/one.html" do
  r = route("bad/one.htm")
  r.respond
  r.has_title("Le titre", 3)
end

test_route "bad/one.html" do |r|
  r.respond
  r.has_title("Le titre", 3)
end
