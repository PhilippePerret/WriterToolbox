# Files et Folders méthodes

* [Méthodes-cases des tfiles et tfolders](#methodescasedetfile)
  * [Méthode `exists` & dérivées](#methodecasetfileexists)

Pour tester les fichiers et les dossiers, on peut utiliser les méthodes de test-méthodes `tfile` et `tfolder`.

> Note&nbsp;: On n'emploie pas `file` ou `folder` qui pourrait interférer avec les méthodes `file` ou `folder` des objets, comme c'est le cas pour `test_user` par exemple.

~~~ruby

test_user 12 do

  tfolder(folder).exists
  # => Produit un succès si le dossier de l'user (retourné par `folder`)
  #    existe.
  
end

<a name='methodescasedetfile'></a>

## Méthodes-cases des tfiles et tfolders

<a name='methodecasetfileexists'></a>

### Méthode `exists` & dérivées

~~~ruby

test_user 12 do

  tfolder(folder).exists
  
end

~~~

Liste des méthodes&nbsp;:

        exists    not_exists    exists?     not_exists?