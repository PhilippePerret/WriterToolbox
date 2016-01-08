# encoding: UTF-8
raise "Section interdite" unless user.admin?

class SiteHtml
class Admin
class Console
  #
  # AIDE
  #
  # À REMPLIR À MESURE QUE DES MÉTHODES S'AJOUTENT
  #
  def help
    <<-HTML
<h4>Généralités</h4>
<dl class='small'>

  <dt>Fonctionnement général</dt>
  <dd>Taper une ligne de code puis presser “Entrée” comme dans une console pour exécuter le code.</dd>
  <dd>Le code est exécuté, le résultat est transmis sous la ligne et le curseur se place pour une nouvelle invite.</dd>
  <dd>Noter qu'à chaque exécution de ligne, <strong>tout le code</strong> sera exécuté dans son intégralité. Donc, afin d'éviter les erreurs et d'alléger la procédure, il est bon de ne garder que ce qui est important.</dd>

  <dt>Code exécutable</dt>
  <dd>On peut exécuter n'importe quel code ruby pur, où les lignes spéciales présentées ci-dessous.</dd>
  <dd>Noter qu'on peut notamment utiliser `site` pour interagir avec le site. Par exemple, le code `site.name` retournera le nom du site.</dd>

  <dt>Exécution du pur code Ruby</dt>
  <dd>Le pur code ruby est interprété tel quel. Par exemple `debug "bonjour le monde !"` écrira "bonjour le monde !" dans le message de débug.</dd>
  <dd>S'il renvoie un résultat, il sera écrit sous la console.</dd>

  <dt>Traitement des variables</dt>
  <dd>Pour le moment, on ne peut pas utiliser de variable. Ce qui signifie que chaque ligne doit s'employer pour elle-même.</dd>
  <dd>Les variables devraient être traitées dans un très proche avenir.</dd>
</dl>

<h4>Lignes de code utilisables</h4>
<dl class='small'>

  <dt>`vide table paiements`</dt>
  <dd>Vider la table des paiements, c'est-à-dire les supprime tous. À utiliser seulement en offline…</dd>

  <dt>`remove table paiements`</dt>
  <dd>ATTENTION : Détruit complètement la table.</dd>
  <dd>La méthode étant "dangereuse", elle n'est possible qu'en OFFLINE.</dd>

  <dt>`montre table &lt;database&gt;.&lt;table&gt;`</dt>
  <dd>Pour afficher le contenu d'une table. NON IMPLÉMENTÉE.</dd>
  <dd>Variante : `montre` peut être remplacé par `affiche`.</dd>

  <dt>`detruire programmes de `&lt;pseudo&gt;|&lt;id&gt;`</dt>
  <dd>Détruit tous les programmes “Un An Un Script” de l'user et détruit aussi son dossier dans `./database/data/unan/user/` comme s'il n'avait jamais procédé à un seul programme. Permet de tester l'inscription au programme.</dd>
  <dd>OFFLINE seulement</dd>
</dl>
    HTML
  end

end #/Console
end #/Admin
end #/SiteHtml
