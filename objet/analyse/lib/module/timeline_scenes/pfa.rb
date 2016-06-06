# encoding: UTF-8
=begin

  Tout ce qui concerne le paradigme de Field augmenté pour
  les timelines des scènes.

=end
class FilmAnalyse
class << self

  # Retourne le code HTML du calque du paradigme de Field
  def calque_pfa
    '<div id="pfa" style="display:none">'   +
      '<div id="pfa-exposition"><span id="pfa-pvt1" class="libelle">Pivot 1</span></div>' +
      '<div id="pfa-1tiers"><span class="libelle">1/3</span></div>' +
      '<div id="pfa-cdv"><span class="libelle">C.d.V.</span></div>' +
      '<div id="pfa-2tiers"><span class="libelle">2/3</span></div>' +
      '<div id="pfa-developpement"><span id="pfa-pvt1" class="libelle">Pivot 2</span></div>'  +
      '<div id="pfa-denouement"></div>'     +
    '</div>'
  end

  # Retourne le DIV des boutons qui servent à gérer le PFA,
  # c'est-à-dire les boutons qui permettent de passer de
  # position-clé en position-clé
  def boutons_pfa
    '<div id="tls_pfa_tools">' +
      '<div id="tls_pfa_tools_nav" style="visibility:hidden">' +
        '<a id="tls_btn_pfa_prev" href="javascript:void(0)" onclick="$.proxy(PFA,\'prev_node\')()">◀︎</a>' +
        '<span id="tls_pfa_nav_libelle">---</span>' +
        '<a id="tls_btn_pfa_next" href="javascript:void(0)" onclick="$.proxy(PFA,\'next_node\')()">▶︎</a>' +
      '</div>' +
      '<div class="right">' +
        '<a id="tls_toggle_pfa" href="javascript:void(0)" onclick="$.proxy(PFA,\'toggle\')()">P.F.A.</a>' +
      '</div>' +
    '</div>'
  end

end # << self
end #/FilmAnalyse
