# encoding: UTF-8
=begin
  Aide pour le collecteur
=end
class FilmAnalyse
class Collector
class << self

  def aide
    site.require_module 'kramdown'
    c = texte_aide.kramdown.in_div(id: 'aide', style: 'display:none')
    c = c.sub(/TDM/, tdm_aide)
    return c
  end


  def texte_aide
    <<-MARKDOWN
<div class="right small visible_when_fixed">Cliquer à nouveau sur le bouton “Aide” pour masquer cette fenêtre.</div>

## Aide du collecteur de film

#{titre 'Présentation', 'presentation', 1}

Cette application en ligne permet de procéder à la collecte d'un film. Elle permet notamment de relever les scènes à la vitesse du film, grâce au compteur de temps.

TDM

#{titre("Procédure simplifiée", 'procedure_simplifiee', 2)}

* On règle le champ “départ” ci-dessous au temps actuel du film,
* on met en route le film tout en cliquant sur le bouton START ci-dessous,
* on tape <code>CTRL + S</code> (`CTRL+CMD+S` sur mac) quand commence une nouvelle scène,
* on écrit son résumé, sa fonction et son synopsis,
* on tape <code>CTRL + H</code> pour ajouter une “horloge” dans la scène, ou <code>CTRL + N</code> pour une note, etc.,
* on retape <code>CTRL + S</code> (`CTRL+CMD+S` sur mac) quand arrive une nouvelle scène,
* on poursuit jusqu'à la fin,
* on arrête le temps en cliquant sur le bouton STOP ci-dessous,
* on affine le texte,
* on enregistre le code obtenu dans un fichier <code>&lt;identifiant_film&gt;.film</code> (fichier appelé “fichier de collecte”).


#{titre 'Liste complète des raccourcis', 'shortcuts_list', 1}

#{general_shortcut_list}
#{collector_shortcut_list}
#{personnages_shortcut_list}
#{brins_shortcut_list}


#{titre 'Mise en route détaillée', 'start_detailled', 1}

Installation
: Le plus simple pour effectuer cette collecte synchronisée est de travailler sur deux ordinateur différent, un pour jouer le film en grand écran et l'autre avec cette application) ou sur un ordinateur et une télévision.
: Il est indispensable, pour utiliser efficacement cet outil, de procéder à la collecte d'un film qu'on aura déjà vu et même qu'on connait assez bien.
: La collecte aura aussi besoin de la définition des personnages. On définit ces personnages en plaçant dans le champ de droite le contenu du fichier <code>&lt;identifiant_du_film&gt;.persos</code> (fichier personnages du film). On peut également définir ces personnages directement dans ce champ. Cf. plus bas dans la partie “Personnages”.
: De la même manière, on peut insérer la définition des brins. Cf. la partie “Brins” ci-dessous.

Mise en route synchronisée du film et de l'analyse
: Afin de permettre d'indiquer automatiquement le temps des scènes, on met le film en pause quelques secondes avant la toute première scène (une quinzaine de secondes).
: On relève la position temporelle actuelle du film (par exemple <code>0:00:36</code>) et on la reporte dans le champ à gauche du bouton START (pour indiquer à l'application le temps de départ de la collecte).
: Puis on relance le film en même temps qu'on clique sur le bouton START.
: Rappel : dans les analyses, on connait le temps de départ (le “zéro absolu du film”) d'après le temps de la toute première scène (même si elle est avant le générique).

Création de la première scène
: Dès que la première scène commence, on tape <code>CTRL + S</code> (`CTRL+CMD+S` sur mac) (“S” comme “Scène” bien sûr).
: Ce raccourci crée une marque de scène avec le temps actuel dans le film.
: Le curseur se place au niveau du synopsis de la scène.

Écriture de la scène
: On écrit la scène de façon simplifiée, façon <em>sténo</em>, pour pouvoir avoir le temps de suivre le film en temps réel.

Insérer une balise personnage dans le texte
: Il ne faut pas écrire les noms des personnages “en dur” dans une scène (sauf s'ils sont cités mais ne sont pas dans la scène). Il faut utiliser une balise personnage qui ressemble à <code>[PERSO#pseudo_id]</code>.
: Pour obtenir la balise personnage, il faut afficher la liste des personnages (<code>CTRL + P</code>), puis on peut soit cliquer sur son pseudo dans le panneau des personnage soit taper <code>CTRL + son indice</code>. La balise perso s'insert automatiquement.

Insérer un temps positionné dans le temps dans la scène
: Dans une scène longue, il peut être utile d'ajouter une position temporelle pour un évènement particulier (un évènement important). On utilise pour ce faire <code>CTRL + H</code> (“H” comme “Horloge”).

Insérer un brin
: De la même manière que les personnages, on peut insérer une balise brin soit pour le résumé, soit pour un paragraphe du synopsis de la scène.
: Pour obtenir cette balise, on affiche la liste des brins (<code>CTRL + B</code>) puis on peut taper son indice si c'est un des 10 premiers brins soit cliquer sur son titre dans la liste.
: Cela ajoute une balise <code>[BRIN#&lt;indice&gt;]</code> au curseur.

Insérer une note
: On peut insérer une note dans la scène en cliquant <code>CLTR + N</code>
: Ces notes doivent être ajoutées après la définition de la scène, c'est-à-dire sur une nouvelle ligne après la marque <code>SCENE:H:MM:SS</code>.

Faire une pause
: Pour faire une pause, il suffit de mettre le film en pause en même temps qu'on appuie sur le bouton STOP de cette interface.
: Avant de relancer la lecture comme au tout départ, on peut ajuster le temps du champ “Départ” et le temps du film, s'il s'est produit un décalage.

Après la première collecte
: Après avoir effectué cette première collecte, on peut reprendre le texte pour l'afficher et mieux le rédiger, on peut retourner à certaines scènes pour avoir des précisions.
: Ensuite, on peut créer un fichier <code>&lt;identifiant_du_film&gt;.film</code> avec le code obtenu pour créer une analyse “TM” qu'on pourra déposer.
: Pour ce faire, penser aussi à ajouter le fichier <code>.persos</code> des personnages.

^

#{titre('Les Personnages', 'personnages',1)}

#{titre('Utilisation de la balise personnage', 'use_personnage_tag', 2)}

Pour pouvoir analyser la présence des personnages dans le film, il ne faut pas utiliser leur nom dans le texte mais une balise <code>[PERSO#&lt;identifiant&gt;]</code>.

Pour obtenir cette balise, il faut que le personnage soit défini (dans un fichier <code>.perso</code> — cf. le mode d'emploi). On peut copier le code de ce fichier dans le champ à droite du champ de collecte.

Ensuite, il suffit de taper CTRL + &lt;indice du personnage 0-start&gt; pour insérer sa balise.

#{texte_aide_personnages}

#{texte_aide_brins}

    MARKDOWN
  end


  def texte_aide_personnages
    <<-MARKDOWN
    #{titre('Définition des personnages', 'define_personnages',2)}

    Les personnages se définissent dans un champ à droite du champ de collecte qu'on fait apparaitre à l'aide du raccourci `CTRL + P` (“P” comme “Personnage”).

    On peut y copier-coller la donnée des personnages normale tirée du fichier `.persos` s'il existe. Sinon, on peut définir les personnages dans ce champ.

    <p class='red'>Si les personnages sont directement créés dans ce champ, il est vivement conseillé de les copier-coller ensuite dans un fichier de nom `<identifiant_du_film&>.persos`, sinon, la correspondance entre les balises et les personnages sera perdue.</p>

    * Afficher la liste des personnages si elle n'est pas affichée (`CTRL + P`),
    * cliquer sur “Redéfinir les personnages” si la liste des personnages est déjà affichée,
    * se placer dans le champ de données des personnages,
    * taper `CTRL + P` pour insérer au curseur une donnée personnage,
    * choisir un identifiant unique pour ce nouveau personnage,
    * taper `TABULATION` pour passer d'une donnée à l'autre,
    * après la définition du personnage, on peut copier-coller tout le texte dans le fichier des personnages du film,
    * sortir du champ pour créer la nouvelle liste de personanges.

    Lorsque le panneau des personnages est déjà créé (il se crée automatiquement en quittant le champ de saisie des données), il suffit d'activer le lien en bas du panneau (scroller jusqu'au bas de la liste des personnages si nécessaire).

    MARKDOWN
  end

  def texte_aide_brins
    <<-MARKDOWN
#{titre('Les Brins', 'brins',1)}

#{titre('Utilisation de la balise brin', 'use_brin_tag', 2)}

Pour pouvoir analyser l'utilisation des intrigues dans le film, il faut utiliser les brins et leur balise `[PERSO#<identifiant>]`.

Pour obtenir cette balise, il faut que le brin soit défini (dans un fichier `<identifiant_film&>.brins` — cf. le mode d'emploi). On peut copier le code de ce fichier dans le champ brin.

Ensuite, il suffit de taper CTRL + &lt;indice du brin 0-start&gt; pour insérer sa balise, ou cliquer son titre dans la liste.

#{titre('Définition des brins', 'define_brins',2)}

Les brins se définissent dans un champ à droite du champ de collecte qu'on fait apparaitre à l'aide du raccourci `CTRL + B` (“B” comme “Brin”).

On peut y copier-coller la donnée des brins normale tirée du fichier `.brins` s'il existe. Sinon, on peut définir les brins dans ce champ.

<p class='red'>Si les brins sont directement créés dans ce champ, il est vivement conseillé de les copier-coller ensuite dans un fichier de nom `&lt;identifiant_du_film>.brins`, sinon, la correspondance entre les balises et les brins sera perdue.</p>

* Afficher la liste des brins si elle n'est pas affichée (`CTRL + B`),
* cliquer sur “Redéfinir les brins si la liste des personnages est déjà affichée,
* se placer dans le champ de données des brins,
* taper `CTRL + B` pour insérer au curseur une donnée brin vierge,
* choisir un identifiant unique pour ce nouveau brin,
* taper `TABULATION` pour passer d'une propriété à l'autre et la définir,
* après la définition du brin, on peut copier-coller tout le texte dans le fichier des brins du film (`<identifiant_film>.brins`),
* sortir du champ pour créer la nouvelle liste de brins.

Pour appeler cette liste et choisir un brin, il suffit, depuis le champ de collecte des scènes, de taper `CTRL + B` si la liste n'est pas affichée.

Lorsque le panneau des brins est déjà créé (il se crée automatiquement en quittant le champ de saisie des données), il suffit d'activer le lien en bas du panneau pour repasser en définition des brins (scroller jusqu'au bas de la liste des brins si nécessaire).

    MARKDOWN
  end

  def general_shortcut_list
    sh_list = [
      ['Afficher/masquer l’aide', 'CTRL + A', '“A” comme “Aide”'],
      ['Nouvelle scène', 'CTRL + S', '“S” comme “Scène”'],
      ['Liste des personnages', 'CTRL + P', '“P” comme “Personnages”'],
      ['Nouveau personnage', 'CTRL + P', '2 fois si la liste n’est pas affichée.'],
      ['Liste des brins', 'CTRL + B', '“B” comme “Brin”'],
      ['Nouveau Brin', 'CTRL + B', '2 fois si la liste des brins n’est pas affichée.'],
    ]

    titre("Raccourcis généraux", 'general_shorcut_list', 2) +
    'Ces raccourcis sont utilisables partout dans l’interface'.in_div(class:'small, italic') +
    build_shortcuts_table(sh_list)

  end
  def collector_shortcut_list
    sh_list = [
      ['Passer à la propriété suivante', 'TAB', ''],
      ['Remonter à la propriété précédente', 'MAJ + TAB', ''],
      ['Insérer une horloge (un temps)', 'CTRL + H', '“H” comme “Horloge”'],
      ['Insérer une note', 'CTRL + N', ''],
      ['Insérer une balise personnage', 'CTRL + &lt;indice&gt;', 'Si la liste est affichée (CTRL + P)'],
      ['Insérer une balise brin', 'CTRL + &lt;indice&gt;', 'Si la liste est affichée (CTRL + B)'],
      ['Aller à la scène suivante', 'CTRL + CMD + S', ''],
      ['Aller à la scène précédente', 'CTRL + MAJ + S', '']
    ]
    titre("Raccourcis collector", 'collector_shorcut_list', 2) +
    'Ces raccourcis ne sont utilisables que dans le champ de saisie des scènes (collector)'.in_div(class:'small, italic') +
    build_shortcuts_table(sh_list)
  end

  def personnages_shortcut_list
    sh_list = [
    ]
    titre("Raccourcis personnages", 'personnage_shorcut_list', 2) +
    'Ces raccourcis ne sont utilisables que dans le champ de saisie des scènes (collector)'.in_div(class:'small, italic') +
    build_shortcuts_table(sh_list)
  end
  def brins_shortcut_list
    sh_list = [
    ]
    titre("Raccourcis brins", 'brins_shorcut_list', 2) +
    'Ces raccourcis ne sont utilisables que dans le champ de saisie des scènes (collector)'.in_div(class:'small, italic') +
    build_shortcuts_table(sh_list)
  end


  def build_shortcuts_table shortcuts
    shortcuts.collect do |scut|
      (
        scut[0].in_td +
        scut[1].in_td +
        scut[2].in_td
      ).in_tr
    end.join.in_table(class: 'raccourcis')
  end

  def tdm_aide
    @tdm ||= Array.new
    @tdm.collect do |dtdm|
      dtdm[:titre].in_a(href:"#", onclick:"$('div#aide').scrollTop($('##{dtdm[:id]}').position().top + 200);return false").in_div(class: "tdm_level#{dtdm[:level]}")
    end.join.in_div(id: 'aide_tdm')
  end

  def titre(titre, id, level)
    @tdm ||= Array.new
    @tdm << {titre: titre, id: id, level: level}
    lev = "h#{level+2}"
    "<#{lev} id='#{id}'>#{top_aide_link}<br><br>#{titre}</#{lev}>"
  end

  def top_aide_link
    @top_aide_link ||= '<div class="right"><a href="#" onclick="$(\'div#aide\').scrollTop(110);return false;">▲</a></div>'
  end

end # << self
end # Collector
end # FilmAnalyse
