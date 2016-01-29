# encoding: UTF-8
class User

  GRADES = {
    # Note par rapport aux privilèges forum : ils sont additionnés, donc
    # par exemple le privilège du 3 reprend toujours les privilèges des
    # 0, 1 et 2
    # Si la description commence par "!!!", elle ne sera ajoutée que pour
    # ce grade.
    0 => {hname:"Padawan de l'écriture",  privilege_forum:"!!!lire les posts publics"},
    1 => {hname:"Simple auditeur",        privilege_forum:"lire tous les posts"},
    2 => {hname:"Auditeur patient",       privilege_forum:"noter les posts"},
    3 => {hname:"Apprenti surveillé",     privilege_forum:"!!!écrire des réponses qui seront modérées"},
    4 => {hname:"Simple rédacteur",       privilege_forum:"répondre librement aux posts"},
    5 => {hname:"Rédacteur",              privilege_forum:"initier un sujet"},
    6 => {hname:"Rédacteur émérite",      privilege_forum:"supprimer des messages"},
    7 => {hname:"Rédacteur confirmé",     privilege_forum:"clore un sujet"},
    8 => {hname:"Maitre rédacteur",       privilege_forum:"supprimer des sujets"},
    9 => {hname:"Expert d'écriture",      privilege_forum:"bannir des utilisateurs"}
  }

end
