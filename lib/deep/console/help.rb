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
<h4 onclick="$('dl#generalites').toggle()">Généralités</h4>
<dl id="generalites" class='small' style="display:none">

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

<h4 onclick="$('dl#code_lines').toggle()">Lignes de codes utilisables</h4>
<dl class='small' id="code_lines" style="display:none">

  <dt>`montre table &lt;database&gt;.&lt;table&gt;`</dt>
  <dd>Pour afficher le contenu d'une table. NON IMPLÉMENTÉE.</dd>
  <dd>Variante : `montre` peut être remplacé par `affiche`.</dd>

  <dt>`vide table paiements`</dt>
  <dd>Vider la table des paiements, c'est-à-dire les supprime tous. À utiliser seulement en offline…</dd>

  <dt>`remove table paiements`</dt>
  <dd>ATTENTION : Détruit complètement la table.</dd>
  <dd>La méthode étant "dangereuse", elle n'est possible qu'en OFFLINE.</dd>

  <dt>`detruire programmes de `&lt;pseudo&gt;|&lt;id&gt;`</dt>
  <dd>Détruit tous les programmes “Un An Un Script” de l'user et détruit aussi son dossier dans `./database/data/unan/user/` comme s'il n'avait jamais procédé à un seul programme. Permet de tester l'inscription au programme.</dd>
  <dd>OFFLINE seulement</dd>
</dl>

<h4 onclick="$('dl#gels').toggle()">Gels et dégels</h4>
<dl class="small" id="gels" style="display:none">
  <dt>list gels</dt>
  <dd>Affiche la liste de tous les gels. Avec une description si le gel en possède une.</dd>
  <dt>`gel 'nom-du-gel'`</dt>
  <dd>Pour geler l'état actuel du site dans le gel de nom 'nom-du-gel'</dd>
  <dd>Ne pas utiliser d'espace dans le nom du gel (de toute façon, ils seront supprimés et remplacés par des traits d'union)</dd>
  <dt>`degel 'nom-du-gel'`</dt>
  <dd>Remet le site dans l'état du gel de nom 'nom-du-gel'.</dd>
  <dt>`site.require_module('gel');Gel::gel('nom-gel', {options})`</dt>
  <dd>Tournure plus complexe à utiliser si des options doivent être transmises. Cf. le manuel sur les gels et les dégels pour plus de détails sur les options.</dd>
</dl>


<!--  PROPRE À L'APPLICATION -->



<h4 onclick="$('dl#unan').toggle()">Lignes propres à l'application (UN AN UN SCRIPT)</h4>
<dl id="unan" class='small' style="display:none;">
  <dt>`Unan ...`</dt>
  <dd>Tous les codes commençant par `Unan` concernent la programme Un An Un Script et chargent automatiquement cet objet avant leur exécution.</dd>

  <dt>`Unan état des lieux` ou `Unan inventory`</dt>
  <dd>Procède à un état des lieux du programme UN AN UN SCRIPT, c'est-à-dire consulte les tables pour faire le rapport. C'est en quelques sortes une version simplifiée de l'affichage de toutes les tables.</dd>

  <dt>`Unan repare`</dt>
  <dd>Répare le programme UN AN UN SCRIPT. Utile souvent après les tests, pour détruire les choses qui ne l'ont pas été à la fin des tests. Mais normalement, maintenant, avec les gels, ça doit être inutile.</dd>

  <dt>`Unan init program for &lt;ID de user existant&gt;`</dt>
  <dd>Pour initier un programme pour un utilisateur existant.</dd>
  <dd>La commande fait plusieurs vérification, notamment l'existence de l'utilisateur et le fait qu'il ne soit pas déjà en train de suivre un programme (qu'il faudrait arrêter avant de poursuivre).</dd>

  <dt>
    <strong>affiche</strong><br />
    <strong>backup data</strong><br />
    <strong>&lt;Modification du schéma de la table&gt;</strong><br />
    <strong>retreive data</strong><br />
  </dt>
  <dd>C'est le cycle de modification d'une table du programme, quand il faut modifier son schéma. On en sauve toutes les données, puis on la reconstruit.</dd>
  <dd>On modifie de schéma de la table (dans `./database/table_definitions`) ;</dd>
  <dd>Après avoir modifié le schéma, il faut indiquer à la méthode `retreive_data` comment elle doit modifier les données enregistrées pour qu'elles correspondent à la nouvelle table. C'est fait dans les méthodes `def retreive_data_...` (chercher cette amorce) dans le fichier `unan_methodes.rb`.</dd>
  <dd><strong>TABLES QUI CONNAISSENT CE CYCLE</strong>
    <ul>
      <li>table programs</li>
      <li>table projets</li>
      <li>`table pages cours` (les pages de cours)</li>
      <li>table quiz (les questionnaires)</li>
      <li>table questions (les questions des questionnaires)</li>
      <li>absolute works (les travaux absolus)</li>
      <li>absolute pdays (les jours absolus)</li>
    </ul>
  </dd>
  <dd>Noter que cette modification affecte les tables courantes mais également toutes les tables des gels, en respectant leurs données propres.</dd>
  
  <dt>`Unan affiche (table absolute pdays)`</dt>
  <dd>Affiche la table des données des jours-programme (P-Days)</dd>
  <dd>Cette table connait le cycle ci-dessus</dd>

  <dt>`Unan affiche (table absolute works)`</dt>
  <dd>Affiche la table des données de travaux absolues</dd>
  <dd>Cette table connait le cycle ci-dessus.</dd>

  <dt>`Unan affiche (table projets)`</dt>
  <dd>Affichage de la liste des projets courants.</dd>
  <dd>Cette table connait le cycle ci-dessus</dd>

  <dt>`Unan affiche (table programs)`</dt>
  <dd>Affichage de la liste des programmes courants.</dd>
  <dd>Cette table connait le cycle ci-dessus</dd>

  <dt>`Unan affiche (table quiz)`</dt>
  <dd>Affichage de la liste des questionnaires.</dd>
  <dd>Cette table connait le cycle ci-dessus</dd>

  <dt>`Unan affiche (table questions)`</dt>
  <dd>Affichage de la liste des questions de questionnaires.</dd>
  <dd>Cette table connait le cycle ci-dessus</dd>

</dl>
    HTML
  end

end #/Console
end #/Admin
end #/SiteHtml
