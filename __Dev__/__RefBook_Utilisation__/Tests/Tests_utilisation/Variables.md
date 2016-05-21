# Gestion des variables

~~~ruby

  let(<nom variable>){ <valeur variable> }
    
~~~

Pour récupérer une variable instanciée de cette manière, on peut utiliser simplement son nom, comme une propriété méthode, dans le code. Mais pour être plus rapide, on peut utiliser la méthode `get`.

Exemples&nbsp;:

~~~ruby

test_base 'users.users' do

  # Met le nombre d'utilisateurs dans la variable test `users_count`
  let(:users_count){ count }
  
end

test_route "ma/route" do

  # On récupère la variable à l'aide de `get`
  nb = get(:users_count)
  html.has_tag("div", text: "#{nb} users")
  
  # Mais on peut faire aussi appel directement à la méthode
  # sans passer par get
  html.has_tag("div", text: "#{users_count} users"
  
end