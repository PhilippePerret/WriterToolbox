# Org-Quiz

Ce module contient les éléments pour parser les questionnaires définis dans des
fichiers Emacs au format org-mode.

## Description du contenu du fichier

~~~

#+TITRE: <le titre principal du questionnaire
#+ID:    <ID du questionnaire, mais seulement s'il est enregistré>
#+TYPE:	 <Le type du questionnaire (quiz, validation des acquis, etc.>

* Une question
  <type> [checkbox|	# Si on ne trouve pas checkbox, c'est un radio-group
   #+ID: <identifiant de la question, nil quand pas encore enregistrée>
** Une réponse
   <note négative, zéro ou positive>

~~~