# encoding: UTF-8
class Unan
class Quiz

  BIT_NO_RESULT = 2
  BIT_COMPTAGE  = 4
  BIT_REQUIRED  = 8

  TYPES = {
    0 => {value:0, hname:"Indéfini"},
    1 => {value:1, hname:"Simple renseignement",  flag: BIT_NO_RESULT},
    2 => {value:2, hname:"Validation acquis",     flag: BIT_REQUIRED},
    3 => {value:3, hname:"Simple quiz",           flag: BIT_COMPTAGE},
    7 => {value:7, hname:"Sondage",               flag: BIT_NO_RESULT},
    8 => {value:8, hname:"[Question] Même type que quiz", flag:0},
    9 => {value:9, hname:"Autre type",            flag:0}
  }
end #/Quiz
end #/Unan
