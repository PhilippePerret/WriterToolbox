# Form case-test

* [Existence du formulaire](#existenceduformulaire)
* [Données du formulaire](#donneesduformulaire)
* [Objet de la requête CURL (`curl_request`)](#objetcurlrequest)
* [Contenu du HEADER retourné](#contenuduheaderretourned)
* [Session-ID de la requête cUlr](#iddesessionscurl)
* [Contenu de la page retournée](#contenudelapageretournee)


~~~ruby

    # data_form définit le formulaire, et notamment la propriété
    # `fields` qui définit les champs. Voir [Données du formulaire](#donneesduformulaire)

data_form = {...}


   # "route/submitting" doit être la route qui TRAITE le formulaire,
   # PAS la route où on trouve le formulaire.
   
test_form "route/submitting", data_form do

  # Pour soumettre le formulaire
  # Noter que le "fill" ci-dessous est un peu abusif dans le sens
  # où c'est le data_form ci-dessous qui remplit déjà le formulaire puisque
  # l'adresse n'est pas celle de la page où on trouve le formulaire mais la
  # route qui TRAITE le formulaire.
  fill_and_submit

end

~~~

---------------------------------------------------------------------

<a name='donneesduformulaire'></a>

## Données du formulaire

~~~ruby

data_form = {
  id: "identifiant du formulaire",
  action: "action/du/formulaire",
  method: "methode POST ou GET",
  fields: {
    champid: {name: "name field", value: "valeur à donner"},
    champid: {name: "name field", value: "valeur à donner"},
    etc.
  }
}

~~~

---------------------------------------------------------------------

<a name='existenceduformulaire'></a>

## Existence du formulaire


~~~ruby

test_form route, data_formulaire do
  exist
end
~~~

Produit un succès si le formulaire à la route `route` existe, défini par les données `data_formulaire`.

<a name='objetcurlrequest'></a>

## Objet de la requête CURL

L'objet de la requête Curl, `curl_request`, est une instance de `SiteHtml::TestSuite::Request::Curl` qui permet d'obtenir des informations sur la requête transmise.

~~~ruby

test_form route, dform do

  # Il faut soumettre le formulaire pour pouvoir utiliser la
  # requête curl
  fill_and_submit

  # La requête curl peut être utilisée pour obtenir le retour
  curl_request.content
  # => Le contenu de la page retournée

end

~~~


<a name='contenuduheaderretourned'></a>

## Contenu du HEADER retourné

On peut tester le header retourné par grâce à la méthode-propriété `curl_request.header`. Ce header est fabriqué par l'instance `SiteHtml::TestSuite::Request::Curl` de la requête et contient toutes les propriétés contenues dans l'header, à commencer par&nbsp;:

~~~

  http_version:       Le version HTTP, p.e. "HTTP/1.1"
  status_code:        Le code d'état, 200 en général si tout est OK
  human_status:       Le statut humain, "OK" en général si tout est OK

  cookies:            Les cookies enregistré par la page. C'est une liste de
                      hash qui contiennent chacun :
                        {
                          "nomducookie" => "valeur du cookie",
                          "path"        => "/path",
                          "expires"     => Time d'expiration
                        }
  content_type:       Le type de contenu, en général "text/html"
                      Valeur de "Content-Type"
  content_length:     La longueur du contenu
                      Valeur de "Content-Length"
  date:               {Date} Date de la requête
                      Valeur de "Date"
  server:             Le type de serveur
                      Valeur de "Server"

  ... tout autre valeur ...
~~~

Pour tester le header retourné, on peut utiliser toutes les `case-méthodes` de l'objet `THash` puisque ce header en est un&nbsp;:

~~~ruby

test_form "mon/form", dform do

  fill_and_submit

  curl_request.header.has(status_code: 200)

end

~~~

<a name='iddesessionscurl'></a>

## Session-ID de la requête cUlr

On peut obtenir l'ID de session de la requête grâce à la méthode `session_id` du case-objet `curl_request` :

~~~ruby

test_form "ma/route", dform do
  fill_and_submit

  show "Session-ID : #{curl_request.session_id}"

end

Noter qu'il faut impérativement définir le nom du cookie dans le fichier de configuration (`./objet/site/config.rb`) si sa valeur par défaut a été modifiée&nbsp;:

~~~ruby

  # in ./objet/site/config.rb
  site.cookie_session_name = "NOMDUCOOKIE"

~~~


<a name='contenudelapageretournee'></a>

## Contenu de la page retournée

On peut obtenir le contenu de la page retournée après la soumission du formulaire à l'aide de la méthode-propriété `content` de `curl_request`&nbsp;:

~~~ruby

test_form "route/form", dform do

  fill_and_submit

  show curl_request.content.gsub(/</, '&lt;')

end

~~~
