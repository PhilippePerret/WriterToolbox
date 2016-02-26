# encoding: UTF-8
class Evc
class Specs

  TYPES = {
    'brin'    => {hname: "Brin"   , id:"brin"},
    'continu' => {hname:"Continu" , id:'continu'},
    'scenier' => {hname: "Scénier", id:"scenier"}
  }

  SCALES = {
    'act'               => {hname: "Acte"            , id:"act"},
    'micro-acte'        => {hname: "Micro-acte"      , id:"micro-acte"},
    'macro-sequenciel'  => {hname: "Macro-séquenciel", id:"macro-sequenciel"},
    'sequenciel'        => {hname: "Séquenciel"      , id:"sequenciel"},
    'macro-cellulaire'  => {hname: "Macro-cellulaire", id:"macro-cellulaire" },
    'scenier'           => {hname: "Scénier"         , id:"scenier"},
    'micro-scenier'     => {hname: "Micro-scénier"   , id:"micro-scenier"},
    'cellulaire'        => {hname: "Cellulaire"      , id:"cellulaire"},
    'atomique'          => {hname: "Atomique"        , id:"atomique"}
  }

end #/Specs
end #/Evc
