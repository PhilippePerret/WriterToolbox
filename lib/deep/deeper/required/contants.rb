# encoding: UTF-8

OUI = "<span class='green'>OUI</span>"
NON = "<span class='warning'>NON</span>"

def picto_info
  @picto_info ||= image('pictos/picto_info.png', {alt:"Infos", class:'btninfo'})
end
