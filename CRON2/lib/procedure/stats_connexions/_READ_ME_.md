
* [Synopsis général](#synoipsisgeneral)
* [Générer le rapport en offline](#genererrapportoffline)

<a name='synoipsisgeneral'></a>

## Synopsis général

La méthode principale générant le rapport est la méthode `generate_report` qui se trouve dans :

    ./CRON2/lib/procedure/stats_connexions/connexion/class/report.rb


<a name='genererrapportoffline'></a>

## Générer le rapport en offline

Pour générer le rapport en OFFLINE, et vérifier qu'il fonctionne bien, il suffit de jouer le test :

    ./spec/unit/cron/connexions/generate_report_spec.rb
