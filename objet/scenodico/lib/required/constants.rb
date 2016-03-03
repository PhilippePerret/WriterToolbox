# encoding: UTF-8

page.title = "Scénodico"

=begin

NOTE : Si ce sont les catégories qui sont recherchées, elles se trouvent
dans une table. Pour les lire, utiliser le code console :

    afficher table scenodico.categories

Pour ajouter une catégorie, utiliser :

    site.require_objet('scenodico');
    Scenodico::table_categories.insert({cate_id:"IDCATEGORIE", hname:"LE NOM HUMAIN DE LA CATEGORIE", description:"LA DESCRIPTION DE LA CATEGORIE"})

=end
