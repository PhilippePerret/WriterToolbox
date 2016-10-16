# Snippets

* [Snippets sur tous les textarea](#textareaavecsnippets)


<a name='textareaavecsnippets'></a>

## Snippets sur les textarea

Pour utiliser les snippets sur un textarea (noter qu'ils ne sont pas posés automatiquement sur les textareas comme sur l'atelier Icare) :

    # Dans le fichier RUBY
    page.add_javascript(PATH_MODULE_JS_SNIPPETS)

    # Dans un fichier javascript chargé
    $(document).ready(function(){
      UI.prepare_champs_easy_edit(tous=true)
    });
