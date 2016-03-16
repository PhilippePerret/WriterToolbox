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

  <dt>`goto &lt;endroit&gt;`</dt>
  <dt>`aller&lt;endroit&gt;`</dt>
  <dd>Pour se rendre rapidement dans une section de la boite</dd>
  <dd>Cf. le fichier ./lib/deep/console/sub_methods/goto_methods.rb pour voir toutes les destinations possibles ou en ajouter d'autres.</dd>
  <dd>
    <ul>
      <li>filmo|filmodico : Le filmodico</li>
      <li>nouveau_film : Pour créer un nouveau film</li>
      <li>sceno|scenodico : rejoindre le scénodico</li>
      <li>nouveau_mot : Pour créer un nouveau mot (ou l'édition par son ID)</li>
      <li>narration : Rejoindre l'accueil de la collection</li>
      <li>new_page_narration : Création d'une nouvelle page de la collection</li>
      <li>livres_narration   : Liste des livres</li>
      <li>forum : Rejoindre le forum</li>
      <li>unanunscript : Rejoindre la section du programme UN AN UN SCRIPT</li>
    </ul>
  </dd>


  <dt>`read debug` ou `show debug`</dt>
  <dd>Pour lire le fichier debug.log.</dd>

  <dt>`destroy debug` ou `kill debug`</dt>
  <dd>Détruire le fichier debug.log</dd>

  <dt>`check synchro`</dt>
  <dd>Procède au check de synchro et génère un fichier HTML pour synchroniser le site distant avec le site local.</dd>

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

<h4 onclick="$('dl#fichiers_et_dossiers').toggle()">Fichiers et dossiers</h4>
<dl class="small" id="fichiers_et_dossiers" style="display:none">
  <dt>`kramdown &lt;./path/to/file.md`</dt>
  <dd>Parse et affiche le fichier Markdown fourni en second argument.</dd>
  <dd>Tip : Dans Atom, trouver le fichier, Ctrl-cliquer dessus et choisir “Copy full path” ou “Copy project path” pour utiliser le résultat en argument. Noter que si c'est le “project path” qui est choisi, il faut ajouter `./` devant.</dd>
</dl>


<!-- DICTIONNAIRES -->
<h4 onclick="$('dl#dictionnaires').toggle()">Dictionnaires</h4>
<dl class="small" id="dictionnaires" style="display:none">
  <dt>`list filmodico`</dt>
  <dd>Affiche la liste des films du Filmodico, c'est-à-dire la table</dd>
  <dt>`balise film &lt;titre ou portion de titre&gt;`</dt>
  <dd>Retourne la balise FILM pour le film demandé, ou les balises si plusieurs films correspondent à la demande.</dd>
  <dd>La recherche se fait par ordre de précédence sur 1/ le film-id, 2/ le titre original et 3/ le titre français.</dd>
  <dt>`balise mot &lt;mot ou portion de mot&gt;`</dt>
  <dd>Retourne la balise MOT pour le mot demandé</dd>
  <dd></dd>
</dl>

<!-- FILMS ET ANALYSES -->
<h4 onclick="$('dl#films_analyses').toggle()">Films et analyses</h4>
<dl class="small" id="films_analyses" style="display:none">

  <dt>`aide analyse`</dt>
  <dd>Pour afficher l'aide pour les analyses de films.</dd>
  <dd>Si des aides doivent être ajoutées, #{lien.edit_file('/Users/philippeperret/Sites/WriterToolbox/lib/deep/deeper/module/console_aides/analyse.rb', titre: "modifier ce fichier")}.</dd>
  <dt>`create film {&lt;data&gt;}`</dt>
  <dd>Créer un enregistrement des infos minimales du film dans la table `analyse.films`.</dd>
  <dd>Les infos minimales sont `{sym:&lt;symbole pour affixe fichier&gt;, titre:&lt;titre du film&gt;}`</dd>
  <dd>Toutes les autres informations sont optionnelles : `:realisateur`, `auteurs`, `pays` (sur deux lettres minuscules), `annee`, `titre_fr`</dd>
  <dd><strong>Propriétés spéciales</strong></dd>
  <dd>On peut ajouter des propriétés spéciales qui en fait seront traités en options :
    <ul>
      <li>analyzed:true / Le film est analysé dans les analyses du site (Film TM)</li>
      <li>lisible:true  / le film est analysé et consultable (:analyzed est donc considéré true)</li>
      <li>completed:true / le film est analysé et l'analyse est terminée (:lisible est donc considéré true)</li>
    </ul>
  </dd>
  <dd>La commande retourne l'identifiant du nouveau film créé.</dd>

  <dt>`update film &lt;id|sym&gt; {&lt;data&gt;}`</dt>
  <dd>Actualise les données d'un film d'identifiant id ou de sym `sym`(rappel : le `sym` sert de nom de fichier).</dd>
  <dd>Noter qu'on peut utiliser les mêmes propriétés spéciales que pour create : analyzed, lisible, etc.</dd>

  <dt>`list films` ou `affiche table films`</dt>
  <dd>Affiche le contenu de la table analyse.films</dd>
  <dt>`list filmodico` ou `affiche filmodico`</dt>
  <dd>Affiche le contenu de la table du Filmodico.</dd>

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
<h4 onclick="$('dl#work_pday_etc').toggle()">Commandes propres aux Works, P-Days et autres Pages de cours</h4>
<dl id="work_pday_etc" class="small" style="display:none;">

  <dt>`set benoit to pday &lt;x p-day (1-start)&gt;`</dt>
  <dd>Passe Benoit à ce jour-programme, en réglant tout ce qu'il faut régler.</dd>
  <dt>`set benoit to pday &lt;x p-day&gt; with {&lt;params&gt;}`</dt>
  <dd>Même que précédente mais en définissant des paramètres supplémentaires.</dd>
  <dd>Ces paramètres peuvent être : <ul>
    <li>`rythme` : Le rythme choisi, de 1 à 9</li>
    <li>`just_in_time` : Si true, l'heure sera mise juste au début du jour, ce qui fait que les travaux précédents devraient être en retard.</li>
  </ul></dd>

  <dt>`get &lt;chose&gt; of &lt;autre_chose&gt; &lt;id&gt;`</dt>
  <dd>Obtient la chose (work, page de cours, p-day etc.) de l'autre chose (work, page de cours, p-day, etc.)</dd>
  <dd>En plus, produit une ligne qui permet d'éditer, d'afficher ou de détruire l'élément voulu.</dd>
  <dd>La ligne suivant détaille la tournure régulière</dd>

  <dt>`get \\<br />(work|pday|page_cours|exemple|quiz) \\<br /> of \\<br />(work|pday|page_cours|exemple|quiz) &lt;id&gt;`</dt>
  <dd>Donne la chose 1 de la chose 2 d'identifiant donné, c'est-à-dire tous les liens permettant de la gérer.</dd>

  <dt>`Unan nouveau pday` ou `Unan new pday`</dt>
  <dd>Conduit au formulaire pour créer un nouveau P-Day</dd>

  <dt>`Unan nouveau work` ou `Unan new work`</dt>
  <dd>Conduit au formulaire pour créer un nouveau travail (Word)</dd>

  <dt>`unan nouvelle page` ou `Unan new page`</dt>
  <dd>Conduit au formulaire pour créer une nouvelle page de cours</dd>

  <dt>`unan new qcm` ou `Unan nouveau quiz`</dt>
  <dd>Conduit au formulaire pour construire un nouveau Quiz</dd>

  <dt>`unan nouvelle question` ou `Unan new question`</dt>
  <dd>Conduit au formulaire pour créer une nouvelle question</dd>

  <dt>`Unan new exemple` ou `Unan nouveau exemple`</dt>

  <dt>`Unan points`</dt>
  <dd>Affiche l'évolution des points sur l'année. Doit permettre de régler les différents grades et messages à obtenir.</dd>
</dl>

<h4 onclick="$('dl#databases').toggle()">Lignes propres aux bases de données</h4>
<dl id="databases" class="small" style="display:none;">
  <dt>`affiche table &lt;path/to/database_sans_db.&gt;.&lt;nom_table&gt;`</dt>
  <dd>Affiche le contenu de la table `nom_table` dans la base de données spécifiée.</dd>
  <dd>Le path vers la base de données se compte à partir du dossier `./database/data/` (qu'il ne faut donc pas mettre).</dd>
  <dd>La méthode prend en main toutes les erreurs et les signale correctement.</dd>
</dl>

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
      <li>table exemples</li>
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

  <dt>`Unan affiche (table exemples)`</dt>
  <dd>Affichage de la liste des exemples donnés pour les cours.</dd>
  <dd>Cette table connait le cycle ci-dessus</dd>

</dl>
    HTML
  end

end #/Console
end #/Admin
end #/SiteHtml
