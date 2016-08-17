# encoding: UTF-8
class UNANProgramme

  TYPES_DOCUMENTS = {
    'STRT'  => {hname: 'Structure'},
    'DYNA'  => {hname: 'Dynamique'},
    'PERS'  => {hname: 'Personnage'},
    'THEM'  => {hname: 'Thématique'},
    'DOCU'  => {hname: 'Documentation'},
    'ANAF'  => {hname: 'Analyse de film'}
  }

  TYPES_TRAVAUX = {
    'WORK'    => {hname: 'AbsWork',     objet: 'abs_work'},
    'PAGE'    => {hname: 'Page cours',  objet: 'page_cours'},
    'EXEMPLE' => {hname: 'Exemple',     objet: 'exemple'},
    'QUIZ'    => {hname: 'Quiz',        objet: 'quiz'}
  }


end #/UNANProgramme
