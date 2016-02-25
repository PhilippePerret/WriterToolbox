# encoding: UTF-8
class Console
class Aide
class << self

  def analyse
    console.sub_log( <<-CODE)
<pre>
---------------------------------------------------------------------
  AIDE ANALYSE DE FILM
---------------------------------------------------------------------

OBTENIR LA LISTE DES FILMS

    $ list films

    Note : Ça n'est pas la liste des films du filmodico qu'on
    obtient par `list filmodico`.

MODIFIER LES OPTIONS D'UN FILM ANALYSÉ

    Dans une fenêtre console :
    $ list films

    Repérer l'ID du film à modifier, puis, dans une autre
    fenêtre :
    $ site.require_objet 'analyse'
    $ FilmAnalyse::table_films.update( &lt;FILM ID>, {options: "&lt;NEW VALEUR>" })

    Note : Cette opération est nécessaire pour pouvoir consulter ou
    publier l'analyse du film.

AJOUTER UN FILM ANALYSÉ

    Pour ajouter un film analysé, il suffit de modifier sa valeur
    `options` (cf. ci-dessus) en mettant son premier nombre à 1
    Régler aussi le second signe pour qu'il dise le degré de visu
    de l'analyse (0 = non visible, 9 = terminée, à partir de 5 =
    lisible).

    ATTENTION : S'assure que le film définisse bien son `sym` et que
    le fichier HTML de l'analyse porte bien ce sym comme affiche
    de nom de fichier.
    
</pre>
    CODE
    ""
  end

end # / << self
end #/Aide
end #/Console
