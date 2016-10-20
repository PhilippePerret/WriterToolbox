# Actualités de l'application (updates)

* [Création d'une nouvelle actualité](#creationnouvelleupdate)


Ces actualités peuvent apparaitre sur la page d'accueil et être envoyées par mail quotidien ou hebdomadaire.

<a name='creationnouvelleupdate'></a>

## Création d'une nouvelle actualité


Pour créer une nouvelle actualité, il suffit d'utiliser le code :

~~~ruby

  site.new_update(<data>)

~~~

Les données doivent être :

~~~ruby

  data = {
    message:    "Le message à faire apparaitre",
    type:       "narration|site|...", # type de l'annonce
    route:      "route/a/suivre",     # la page, if any
    annonce:    0-2,      # 0: pas d'annonce, 1: annonce à tous, 2: aux abonnés
    degre:      0-9,    # Degré d'importance
    created_at:  Time.now.to_i,
    updated_at:  Time.now.to_i
  }
~~~
