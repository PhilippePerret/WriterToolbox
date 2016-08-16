# encoding: UTF-8
class UNANProgramme

  TYPES_DOCUMENTS = {
    'STRT' => {hname: 'Structure'},
    'DYNA'  => {hname: 'Dynamique'},
    'PERS'  => {hname: 'Personnage'},
    'THEM'  => {hname: 'Thématique'},
    'DOCU'  => {hname: 'Documentation'},
    'ANAF'  => {hname: 'Analyse de film'}
  }

  TYPES_TRAVAUX = {
    'WORK'  => {hname: "Travail absolu"},
    'PAGE'  => {hname: "Page cours"}
  }

  REG_SEGMENT_PDAYS = /JP ([0-9]{3,3})-([0-9]{3,3})/
  REG_PDAY = /JP ([0-9]{3,3})/

  REG_TRAVAIL = /\[(WORK|PAGE)( [0-9]+)?\]/

end #/UNANProgramme
