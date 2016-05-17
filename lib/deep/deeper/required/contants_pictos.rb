# encoding: UTF-8
# DOIGT       = "<span style='font-size:18pt;'>☛ </span>".freeze
# DOIGT_ROUGE = "<span style='color:red;font-size:18pt;'>☛ </span>".freeze

def picto_info
  @picto_info ||= image('pictos/picto_info.png', {alt:"Infos", class:'btninfo'}).freeze
end


def picto_doigt color
  "<img src='./view/img/pictos/finger_#{color}.png' class='pdoigt' />".freeze
end
DOIGT         = picto_doigt('black')
DOIGT_ROUGE   = picto_doigt('red')
DOIGT_WHITE   = picto_doigt('white')
DOIGT_GOLD    = picto_doigt('gold')

ARROW         = "<span style='font-family:\"Lucida Grande\",Helvetica,sans-serif;font-size:30px;vertical-align:bottom;'>→</span>"
ARROW_RED     = "<span class='red' style='font-family:\"Lucida Grande\",Helvetica,sans-serif;font-size:30px;vertical-align:bottom;'>→</span>"
ARROW_BLUE    = "<span class='blue' style='font-family:\"Lucida Grande\",Helvetica,sans-serif;font-size:30px;vertical-align:bottom;'>→</span>"

FLASH = "<img src='./view/img/pictos/flash.png' class='pflash' />".freeze

def picto_punaise color
  "<img src='./view/img/pictos/punaise_#{color}.png' class='ppunaise' />".freeze
end
PUNAISE_ROUGE = picto_punaise('red')
PUNAISE_WHITE = picto_punaise('white')
PUNAISE_GOLD  = picto_punaise('gold')
