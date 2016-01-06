# encoding: UTF-8
=begin
Sujets targets pour les types d'étapes, de travaux, de questions etc.

Cette donnée permet d'établir le menu et sous-menus qui permet de
déterminer la cible du travail ou du type. Une méthode permet de
renvoyer le code HTML du menu, qui est actualisé dès que ce fichier
est modifié.
=end

# Noter que les IDs ne doivent pas excéder 1 chiffre, pour être
# utiliser dans les données chiffrées. Par exemple, dans le "type" de
# l'étape absolue de travail, le premier chiffre concerne
# cette cible et le deuxième concerne la sous-cible
SUJETS_CIBLES = {
  histoire:     { value:'0', hname:"Histoire",
    sub:{
      fondamentales:      {value:'0', hname:"Fondamentales"},
      pitch:              {value:'1', hname:"Pitch"},
      synopsis:           {value:'2', hname:"Synopsis"}
    }
  },
  personnage:   { value:'1', hname:"Personnage",
    sub:{
      caracteristiques:   {value:'0', hname:"Caractéristique(s)"},
      dialogue:           {value:'2', hname:"Dialogue"}
    }
  },
  structure:    { value:'2', hname:"Structure",
    sub:{
      plan:     {value:'0', hname:"Plan général"}
    }
  },
  thematique:   { value:'3', hname:"Thématique",
    sub:{

    }
  },
  intrigues:    {value:'4', hname:"Intrigues",
    sub:{
      
    }
  }
}
