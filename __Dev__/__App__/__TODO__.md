# Placer le texte :

Écrire une histoire plus personnelle et plus passionnée. Ou écrire avec passion une écrire plus passionnée et plus personnelle
Éviter les sentiers battus et les histoires trop prévisibles : penser au contraire (le Principe du contraire <= principe créateur de haut niveau)

# Commande `kramdown <path> pdf`

Elle doit pouvoir sortir n'importe quel fichier, ERB, Markdown, en PDF.

Il faut que ce soit une fonction générale, une extesion de la classe SuperFile, qui s'occupe de ça. Cf. le dossier ./lib/deep/deeper/module/latex qui a été initié et dans lequel tous les éléments peuvent se trouver.

Pour ce faire, on doit fonctionner dans un dossier réservé à Latex où les éléments de base se trouveront (cf. l'idée avec la collection). Le code du document sera converti, puis inséré dans un gabarit de document LaTex type article.

Après l'opération, expliquer qu'on peut modifier le document .tex pour obtenir un autre rendu.

Peut-être permettre de mettre des options supplémentaires après le `pdf` de la ligne de commande, en `variable: valeur`, pour indiquer des choses comme le fait que c'est un format `book` qui doit sortir, ce genre de chose.
