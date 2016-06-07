# encoding: UTF-8
class User
  VARIABLES_TYPES = [String, Fixnum, Bignum, Float, Hash, Array, NilClass]


  GRADES = {
    # Note par rapport aux privilèges forum : ils sont additionnés, donc
    # par exemple le privilège du 3 reprend toujours les privilèges des
    # 0, 1 et 2
    # Si la description commence par "!!!", elle ne sera ajoutée que pour
    # ce grade.
    0 => {hname:'Padawan de l’écriture',  privilege_forum:'!!!lire les posts publics'},
    1 => {hname:'Simple auditeur',        privilege_forum:'lire tous les posts'},
    2 => {hname:'Auditeur patient',       privilege_forum:'noter les posts'},
    3 => {hname:'Apprenti surveillé',     privilege_forum:'!!!écrire des réponses qui seront modérées'},
    4 => {hname:'Simple rédacteur',       privilege_forum:'répondre librement aux posts'},
    5 => {hname:'Rédacteur',              privilege_forum:'initier un sujet'},
    6 => {hname:'Rédacteur émérite',      privilege_forum:'supprimer des messages'},
    7 => {hname:'Rédacteur confirmé',     privilege_forum:'clore un sujet'},
    8 => {hname:'Maitre rédacteur',       privilege_forum:'supprimer des sujets'},
    9 => {hname:'Expert d’écriture',      privilege_forum:'bannir des utilisateurs'}
  } unless defined?(GRADES) # quand tests, car on reload ce module


  # Les redirections possibles après l'identification
  # La clé est la valeur enregistrées dans les préférences
  # de l'user (<user>.preference :goto_after_login)
  GOTOS_AFTER_LOGIN = {
    '0' => { hname: 'votre profil', route: nil },
    '1' => { hname: 'votre dernière page consultée', route: nil},
    '2' => { hname: 'votre programme UN AN UN SCRIPT', route: 'bureau/home?in=unan'},
    '3' => { hname: 'l’accueil du site', route: 'site/home'},
    '4' => { hname: 'la collection Narration', route: 'cnarration/home'},
    '5' => { hname: 'le forum', route: 'forum/home'},
    '6' => { hname: 'les analyses de film', route: 'analyse/list'},

    '8' => { hname: 'le dashboard administration', route: 'admin/dashboard', admin: true},
    '9' => { hname: 'la console', route: 'admin/console', admin: true}
  }
end
