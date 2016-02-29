# Fichiers Markdown

* [Transformer un fichier Markdown en code HTML](#transformerundocumentencodehtml)
* [Code retourné ou écrit dans un fichier](#coderetourneouecrit)
  * [Note sur code ERB](#notesurcodeerb)
* [Autre formats en sortie](#autreformatdesortie)
  * [Écriture du code dans un fichier](#sortiedansunfichier)

Ou plus exactement des fichiers `kramdow`.

<a name='transformerundocumentencodehtml'></a>

## Transformer un fichier Markdown en code HTML

Le fichier doit être exprimé comme instance `SuperFile`.

    site.require_module 'kramdown'
    
    <superfile>.kramdown

Ce code retourne le contenu du fichier `<superfile>`, qui doit être au format kramdown, en code HTML.

<a name='coderetourneouecrit'></a>

## Code retourné ou écrit dans un fichier

Par défaut, le code, au format voulu, est retourné par la méthode `kramdown` du SuperFile.

Pour l'écrire plutôt dans un fichier, il suffit de définir l'option `:in_file` :

    <superfile>.kramdown( in_file: "./path/to/mon_file.html" )

Noter que si l'extension n'est pas fournie, elle est définie automatiquement en fonction du format du code de sortie.

<a name='notesurcodeerb'></a>

### Note sur code ERB

Le code ERB à l'intérieur d'un fichier (`<% ... ici ... %>`) doit rester assez simple car seules les balises sont protégées avant que le document ne soit “kramdowné”. Si le code est trop complexe, il risque d'être transformé par ce kramdownage, avec les effets néfastes qu'on pourrait imaginer.

<a name='autreformatdesortie'></a>

## Autres formats en sortie

Par défaut, le code de sortie est de l'ERB. Pour obtenir un autre format, définir dans les options la valeur de `output_format`. Pour le moment, seules les valeurs suivantes sont possibles :

     Valeurs possibles pour output_format
    --------------------------------------
      :erb        HTML + ERB (par défaut)
      :html       Sort du code HTML intégral
      :latex      Sort le code en latex

<a name='sortiedansunfichier'></a>

### Écriture du code dans un fichier

En définissant l'option `:in_file`, on demande à la méthode d'enregistrer le code dans un fichier.

`:in_file` peut avoir deux types de valeurs :

    TRUE      Si :in_file est true, on prend le chemin d'accès du fichier
              markdown et on change son extension en fonction du format de
              sortie.

    {String}  Si :in_file est un string, c'est le chemin d'accès du fichier
              dans lequel il faut écrire le code final.

* [Formatage spéciaux en fonction de l'application](#formatagesspeciauxenfonctiondelapp)
<a name='formatagesspeciauxenfonctiondelapp'></a>

## Formatage spéciaux en fonction de l'application

Si des formatages spéciaux sont à exécuter sur les codes de l'application avant écriture, il faut les définir dans la méthode d'instance de String : `String#formate_balises_propres`. Cette méthode doit retourner le code transformé, ne pas transformer la variable.
