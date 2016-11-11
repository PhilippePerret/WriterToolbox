# User Interface

* [Bloquer la fenêtre](#bloquerfenetre)


<a name='bloquerfenetre'></a>

## Bloquer la fenêtre

Parfois, il peut être utile de "bloquer" la fenêtre, i.e. de la mettre en position `fixed` pour qu'elle ne "saute" pas. Pour ce faire, il suffit d'ajouter en bas de la vue le code :

    <script type="text/javascript">
    $(document).ready(function(){UI.bloquer_la_page(true)})
    </script>

Note : si la vue possède un fichier .js associé, on peut simplement copier à la fin le code entre les balises script.

    $(document).ready(function(){UI.bloquer_la_page(true)})

Si la vue possède déjà un code on-ready, on peut juste mettre :

    UI.bloquer_la_page(true)
