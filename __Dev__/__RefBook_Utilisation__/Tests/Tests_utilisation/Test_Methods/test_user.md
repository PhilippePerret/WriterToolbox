# Test-méthode `test_user`

Pour tester l'utilisateur.

* [Case-test `has_mail` & dérivées](#casemethodehasmailetderivees)


<a name='casemethodehasmailetderivees'></a>

## Case-test `has_mail` & dérivées

@usage

~~~ruby

  test_user user_id do
    
    has_mail(<data mail>)
    
  end
  
~~~

Où `data_mail` peut contenir&nbsp;:

~~~

  :send_after   {Fixnum}  Timestamp de la date après laquelle le mail doit
                avoir été envoyé.
  :send_before  {Fixnum}  Timestamp de la date avant laquelle a eu lieu l'envoi
  
  :subject      {String|Regexp|Array} Le texte que doit contenir le sujet (non
                strict)
  :message      {String|Regexp|Array} Le ou les texte que doit contenir 
                le mail.
  :strict       Mettre à true si on veut rechercher les textes de façon stricte
                donc strictement exacte.
  :count        Le nombre de messages qui doivent être trouvés

~~~

Note : Les `subject` et `message` utiliseront des TString pour tester.