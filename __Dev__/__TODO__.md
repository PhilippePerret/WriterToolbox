# TODO list

Utiliser plutôt les tâches mais ce fichier permet de détailler des choses.

* [Connexion directe de Icare vers BOA](#connexionicaretoboa)


<a name='connexionicaretoboa'></a>

## Connexion directe de Icare vers BOA

Cette procédure doit permettre à un icarien identifié de rejoindre la boite à outils en étant identifié.

Deux fonctionnements :

* Un icarien s'identifie sur la boite à outils et il est automatiquement reconnu en checkant l'atelier icare (SSH)
* Un icarien identitifié sur Icare rejoint LA BOITE À OUTILS et il est reconnu.

### Rejoindre BOA en étant identifié

* L'icarien s'est identifié sur Icare
* Un lien le renvoie vers LA BOITE À OUTILS
* Il clique sur le lien
* Ce lien contient un code
* Par SSH on dépose sur BOA un fichier contenant 1/ le numéro de session de l'icare et le code enregistré dans l'URL
* Sur BOA, on vérifie 1/ son numéro de session, 2/ le code qui est envoyé par l'URL et on les compare au fichier déposé
* S'ils correspondent, on identifie l'icarien

> Note : C'est utile pour la collection Narration si on veut renvoyer l'icarien dessus

    * Creation du lien avec le code MD5
    <> L'utilisateur clique sur le lien
    => On rejoint la page (sur icare) qui le traite
    * Par SSH, la page enregitre le code MD5 et le numéro de session sur
      le site BOA
    * Puis la page redirige vers BOA
    * L'utilisateur arrive sur BOA
    * La page de réception capte le code MD5 (p.e. au nom de variable dans
      l'URL qui s'appelle `autoconnect`)
    * La page vérifie avec le fichier qui a été enregistré
    * Si l'ID session et le code MD5 correspondent => identification
    Question : Mais est-ce que l'ID session est le même ??? Ça me parait
    improbable, sinon ça serait facile de pirater.
    Note : On peut envoyer dans le fichier, aussi, les informations sur
    l'icarien pour l'enregistrer dans la boite à outils.

### Reconnu en s'identifiant sur BOA

Fonctionnement :

* L'icarien se loggue.
* Par SSH, on vérifie son identité sur Icare
* On retourne le résultat
