# encoding: UTF-8
=begin

Facture

=end

# ---------------------------------------------------------------------
#   CALCUL FACTURE
# ---------------------------------------------------------------------

def bouton_calculer
  onclick = "$.proxy(Facture,'calculer')();return false;"
  Facture::button_name_calculer.in_a(href:"", id:"btn_calcul_montant_amount", onclick:onclick, class:'btn small', style:'vertical-align:top')
end

# Menu pour choisir le type de montant
def select_type_montant
  [
  	['montant_ht', "Montant Hors-Taxe"],
  	['montant_ttc', "Montant TTC"],
  	['montant_net', "Net à payer"]
  ].in_select(id:'facture_montant_id', name:"facture[montant_id]")
end

# Champ de saisie pour entrer le montant
def input_text_montant
  "".in_input_text(class:'medium', name:'facture[montant_amount]', id:'facture_montant_amount')
end

# ---------------------------------------------------------------------
#   MISE EN FORME FACTURE
# ---------------------------------------------------------------------

# Retourne un DIV pour le montant +montant_id+ avec le
# libellé +libelle+
def div_montant_facture montant_id, libelle # p.e. "assurance_maladie", "Assurance maladie"
	(
		libelle.in_div(id:"texte-#{montant_id}", class:'intitule-montant')+
		" €".in_div(id:"montant_#{montant_id}", class:'montant-montant')
	).in_div(id:"div_#{montant_id}", class:'montant')
end

def mention_arrondissements
  "(*) Montant des cotisations arrondi à l’euro le plus proche, selon convention AGESSA".in_div(id:"mention_agessa", class:'small hidden_when_calcul')
end

def signature_emetteur
  (user.patronyme || "John DOE").in_div(id:'signature_emetteur', class:'hidden_when_calcul')
end

def emplacement_signature
  "Signature".in_div(id:'emplacement_signature', class:'hidden_when_calcul hidden_when_print')
end


# ---------------------------------------------------------------------
#   Entête de la facture
# ---------------------------------------------------------------------
def entete_facture
  <<-HTML

<div id="entete_facture" class='hidden_when_calcul'>
	<div id="div_date_facture">
	  <span>à </span><span id='lieu_facture'></span>
    <span>le </span><span id='date_facture'>#{Time.now.to_i.as_human_date}</span>
	</div>
	<!-- ÉMETTEUR/AUTEUR -->
	<div id="coordonnees" class="coordonnees">
		<div id="emetteur_facture"></div>
    <pre id="emetteur_adresse"></pre>
	</div>

  <!-- TYPE DE LA FACTURE -->
	<div id="facteur_type">FACTURE <span id="emetteur_statut">AUTEUR</span></div>

	<!-- CLIENT -->
	<div id="coordonnees_client" class="inteligne">
		<div class="italic tiny">Facture adressée à :</div>
		<div id="client_name">LE CLIENT</div>
		<pre id="client_adresse"></pre>
	</div>

	<div class="div_facture_numero">
		<span>FACTURE N°</span><span id="facture_numero">XXXX</span>
	</div>

	<!-- OBJET -->
	<div id="div_facture_objet">OBJET : <span id='facture_objet'>OBJET FACTURE</span></div>

</div><!-- / #entete_facture -->

  HTML
end
