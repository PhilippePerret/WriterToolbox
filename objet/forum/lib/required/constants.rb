# encoding: UTF-8
class Forum

  # Data des catégories
  CATEGORIES = {
    boa: {
      hname: "la Boite à Outils de l'Auteur",
      id: 1,
      description: "Tout ce qui concerne le site dans son ensemble, son fonctionnement, ses administrateurs, etc."
    },
    forum: {
      hname: "Le forum et son fonctionnement",
      id: 2,
      description:"Tout ce qui concerne le forum, le règlement, la charte de bonne conduite, etc."
    },
    unanunscript:{
      hname: "Le programme UN AN UN SCRIPT",
      id: 3,
      description: "Tout ce qui concerne le programme UN AN UN SCRIPT, les documents à commenter, les résultats, etc."
    },
    ecriture:{
      hname:"L'Écriture",
      id: 4,
      description: "Tout ce qui concerne l'écriture en général, questions et témoignages."
    },
    projets_persos:{
      hname:"Annonces et projets personnels",
      id: 5,
      description: "Partagez vos projets personnels, votre calendrier du moment, vos annonces, etc."
    },
    autre:{
      hname:"Sujets divers",
      id: 99,
      description: "Tout ce qui ne peut pas être traité dans les autres catégories."
    }
  }
end
