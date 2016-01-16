# Data Checker

“Data Checker” est une classe qui permet de checker facilement les données avant de les enregistrer.

Toutes les explications se trouvent dans le manuel `./lib/deep/deeper/module/Data_Checker_Manuel.md`.

Rappel rapide :

    require './lib/deep/deeper/module/data_checker'
    ou, si à l'intérieur d'une méthode :
    def save
      (site.folder_deeper_module + 'data_checker.rb').require
      ...
    end

    # dans la class
    include DataChecker

    # Définir les données du check
    def definition_values
      {
        <prop>: {type: <type>, hname: <Le nom>, etc.}
        etc.
      }
    end

    # Lancer le check sur les données
    # contenues dans le hash +data+
    def check_values
      result = data.check_data( definition_values )
      if result.ok
        # => Les données sont valides
        data = result.objet # pour obtenir les données épurées
        ... etc. ...
      else
        # erreurs par propriété dans result.errors ({Hash})
        # Les valeurs sont des Hash définissant :err_code et
        # :err_message. C'est :err_message qui doit surtout être
        # utilisé puisque :err_code correspond à un code connu
        # du data-checker seulement.
      end
    end
