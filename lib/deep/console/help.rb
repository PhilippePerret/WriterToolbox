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

<h4>Lignes de codes utilisables</h4>
<dl class='small'>

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
<!--  PROPRE À L'APPLICATION -->
<h4>Lignes propres à l'application</h4>
<dl>
  <dt>`Unan ...`</dt>
  <dd>Tous les codes commençant par `Unan` concernent la programme Un An Un Script et chargent automatiquement cet objet avant leur exécution.</dd>

  <dt>`Unan affiche (table pages cours)`</dt>
  <dd>Affiche le contenu complet de la table des pages de cours</dd>
  <dt>`Unan backup data (table pages cours)`</dt>
  <dd>Faire une copie des données dans un PStore. Cela permet, combiné à la méthode suivante, de modifier les tables en préservant les données.</dd>
  <dd>Le schéma classique d'utilisation est :
    <ol>
      <li>Cette méthode pour faire le backup des données ;</li>
      <li>On détruit la table avec `Unan destroy etc.` ;</li>
      <li>On modifie de schéma de la table (dans `./database/table_definitions`) ;</li>
      <li>On définit la procédure de modifications des anciennes données ;</li>
      <li>On lance la méthode `Unan retreive data etc.` pour récupérer les données en les traitant pour les injecter dans la table modifiée.</li>
    </ol>
  </dd>
  <dt>`Unan destroy (table pages cours)`</dt>
  <dd>(!!! DANGER !!!)Détruire totalement la table des pages de cours (table qui contient toutes les données et notamment les handlers).</dd>
  <dd>Attention, cette destruction est définitive et doit être opérée quand on possède un backup.</dd>
  <dt>`Unan retreive data (table pages cours)`</dt>
  <dd>Récupération des données placées dans le PStore par la méthode précédente.</dd>
  <dd>Définir dans le fichier `unan_methodes.rb`, dans la méthode `retreive_data_pages_cours`, la procédure de modification appelée `proc_modif`.</dd>

  <dt>`Unan affiche (table absolute pdays)`</dt>
  <dd>Affiche la table des données des jours-programme (P-Days)</dd>
  <dt>`Unan backup data (table absolute pdays)`</dt>
  <dd>Faire une copie des données dans un PStore. Cela permet, combiné à la méthode suivante, de modifier les tables en préservant les données.</dd>
  <dd>Voir pour la méthode plus haut pour les pages de cours l'explication complète de la procédure classique de modification d'une table sans perte des données.</dd>
  <dt>`Unan destroy (table absolute pdays)`</dt>
  <dd>(!!! DANGER !!!) Détruit totalement la table des données absolues des p-days (jours-programme).</dd>
  <dt>`Unan retreive data (table absolute pdays)`</dt>
  <dd>Récupération des données placées dans le PStore par la méthode précédente.</dd>
  <dd>Définir dans le fichier `unan_methodes.rb`, dans la méthode `retreive_data_absolute_pdays`, la procédure de modification appelée `proc_modif`.</dd>

  <dt>`Unan affiche (table absolute works)`</dt>
  <dd>Affiche la table des données de travaux absolues</dd>
  <dt>`Unan backup data (table absolute works)`</dt>
  <dd>Faire une copie des données dans un PStore. Cela permet, combiné à la méthode suivante, de modifier les tables en préservant les données.</dd>
  <dd>Voir pour la méthode plus haut pour les pages de cours l'explication complète de la procédure classique de modification d'une table sans perte des données.</dd>
  <dt>`Unan destroy (table absolute works)`</dt>
  <dd>(!!! DANGER !!!) Détruit totalement la table des données absolues de travaux.</dd>
  <dt>`Unan retreive data (table absolute works)`</dt>
  <dd>Récupération des données placées dans le PStore par la méthode précédente.</dd>
  <dd>Définir dans le fichier `unan_methodes.rb`, dans la méthode `retreive_data_absolute_works`, la procédure de modification appelée `proc_modif`.</dd>

  <dt>`Unan affiche (table projets)`</dt>
  <dd>Affichage de la liste des projets courants.</dd>
  <dt>`Unan backup data (table projets)`</dt>
  <dd>Faire une copie des données dans un PStore. Cela permet, combiné à la méthode suivante, de modifier les tables en préservant les données.</dd>
  <dt>`Unan destroy (table projets)`</dt>
  <dd>(!!! DANGER !!!) Détruit totalement la table des données des projets. Par mesure de précaution, cette commande ne peut être appelée ONLINE.</dd>
  <dd>Voir pour la méthode plus haut pour les pages de cours l'explication complète de la procédure classique de modification d'une table sans perte des données.</dd>
  <dt>`Unan retreive data (table projets)`</dt>
  <dd>Récupération des données placées dans le PStore par la méthode précédente.</dd>
  <dd>Définir dans le fichier `unan_methodes.rb`, dans la méthode `retreive_data_projets`, la procédure de modification appelée `proc_modif`.</dd>

  <dt>`Unan affiche (table programs)`</dt>
  <dd>Affichage de la liste des programmes courants.</dd>
  <dt>`Unan backup data (table programs)`</dt>
  <dd>Faire une copie des données dans un PStore. Cela permet, combiné à la méthode suivante, de modifier les tables en préservant les données.</dd>
  <dt>`Unan destroy (table programs)`</dt>
  <dd>(!!! DANGER !!!) Détruit totalement la table des données des projets. Par mesure de précaution, cette commande ne peut être appelée ONLINE.</dd>
  <dd>Voir pour la méthode plus haut pour les pages de cours l'explication complète de la procédure classique de modification d'une table sans perte des données.</dd>
  <dt>`Unan retreive data (table programs)`</dt>
  <dd>Récupération des données placées dans le PStore par la méthode précédente.</dd>
  <dd>Définir dans le fichier `unan_methodes.rb`, dans la méthode `retreive_data_programs`, la procédure de modification appelée `proc_modif`.</dd>

</dl>
    HTML
  end

end #/Console
end #/Admin
end #/SiteHtml
