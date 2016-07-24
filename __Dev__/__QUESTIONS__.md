# Questions

## Quel système pour tester les bases de données ?

* Faut-il faire toujours des copies des bases existantes ?
* Comment intégrer les gels actuels ? => la commande `gel`/`degel` en test-méthodes (ou plutôt en méthode de SiteHtml::TestSuite::TestFile)


### Test des bases :

* Les méthodes complètes de base, donc en "test-méthode"
* Les "case-méthodes" propres à ces test-méthodes
* Les case-méthodes générales qu'on peut utiliser partout

~~~ruby

  # Test-méthode
  test_base "path/to/base_sans_db.table" do

  end

~~~

Ne pourrait-on pas utiliser les test-méthodes imbriquées :

~~~ruby

  test_form "user/login", data_form do
    fill_and_submit(login_mail: nil)
    test_base "users.connexions" do
      row(...).not_exists
      OU
      has_not_row(...)
    end
    fill_and_submit(login_mail: "bon@mail.fr")
    test_base "users.connexions" do
      row(...).exist
      OU
      has_row
    end
  end
~~~
