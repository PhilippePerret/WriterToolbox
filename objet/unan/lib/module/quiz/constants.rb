# encoding: UTF-8
class Unan
class Quiz

  TYPES = {
    0 => {value:0, hname:"Indéfini",              type_v: :none},
    1 => {value:1, hname:"Simple renseignement",  type_v: :renseignements},
    2 => {value:2, hname:"Validation acquis",     type_v: :validation_acquis},
    3 => {value:3, hname:"Simple quiz",           type_v: :simple_quiz},
    7 => {value:7, hname:"Sondage",               type_v: :renseignements},
    8 => {value:8, hname:"[Question] Même type que quiz", type_v: :none},
    9 => {value:9, hname:"Autre type",            type_v: :simple_quiz}
  }
end #/Quiz
end #/Unan
