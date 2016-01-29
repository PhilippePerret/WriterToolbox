# encoding: UTF-8
class Forum
class Sujet

  # Types de sujet
  # Détermine l'affichage et la gestion des votes
  TYPES = {
    0 => {
      value:0,  hname:"Indéfini", description: nil,
      feminine:false, htype:"Indéfini", titre_new_post: "Nouveau message"},
    1 => {value:1,  hname:"Sujet de forum normal", description: "Les messages apparaissent les uns en dessous des autres, de façon chronologique.",
      feminine:false, htype:"Topic", titre_new_post:"Nouveau message"},
    2 => {value:2,  hname:"Question technique (type StackOverflow)", description: "Les messages les plus cotés apparaissent en premier, sous la question.",
      feminine:true, htype:"Question", titre_new_post:"Répondre"},
    9 => {value:9,  hname:"Autre",
      feminine:false, htype:"Autre", titre_new_post:"Nouveau message"}
  }
end #/Sujet
end #/Forum
