# encoding: UTF-8
class Citation

  include MethodesObjetsBdD

  attr_reader :id

  def initialize id
    @id = id
  end

  def citation    ; @citation     ||= get(:citation)    end
  def auteur      ; @auteur       ||= get(:auteur)      end
  def source      ; @source       ||= get(:source)      end
  def description ; @description  ||= get(:description) end
  def created_at  ; @created_at   ||= get(:created_at)  end

  def output
    citation.in_div(class: 'big air') +
    auteur.in_div(class: 'right italic') +
    source_humaine +
    boutons_edition +
    description_if_any
  end

  def source_humaine
    @source_humaine ||= begin
      if source.nil?
        ""
      else
        source.in_div(class: 'right small italic')
      end
    end
  end

  def boutons_edition
    user.manitou? || ( return '' )
    (
      'Nouvelle citation'.in_a(href: 'citation/edit') +
      "Editer la citation ##{id}".in_a(href: "citation/#{id}/edit")
    ).in_div(class: 'small right btns')
  end

  def description_if_any
    @description_if_any ||= begin
      if description.nil? || description == ''
        ''
      else
        'Explicitation'.in_h4(class: 'libelle', style: 'margin-top: 4em') +
        description.in_div(id: 'explicitation_citation')
      end
    end
  end

  def table
    @table ||= site.db.create_table_if_needed('site_cold', 'citations')
  end

end