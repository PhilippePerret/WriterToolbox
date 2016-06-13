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
  def last_sent   ; @last_sent    ||= get(:last_sent)   end
  def bitly       ; @bitly        ||= get(:bitly)       end
  def created_at  ; @created_at   ||= get(:created_at)  end

  def output
    citation.in_div(class: 'big air') +
    auteur.in_div(class: 'right italic') +
    source_humaine +
    boutons_edition +
    description_if_any
  end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------
  def long_url
    @long_url = "#{site.distant_url}/citation/#{id}/show"
  end

  def short_url
    @short_url ||= begin
      self.bitly || begin
        require './objet/bitly/main.rb'
        rsbitly = RSBitly.new
        rsbitly.long_url = long_url
        rsbitly.short_url # la crée si nécessaire
      end
    end
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
      'Nouvelle citation'.in_a(href: 'http://localhost/WriterToolbox/citation/edit') +
      "Editer la citation ##{id}".in_a(href: "http://localhost/WriterToolbox/citation/#{id}/edit") +
      '&lt;...&gt;'.in_a()
    ).in_div(class: 'small right btns')
  end

  def description_if_any
    @description_if_any ||= begin
      if description.nil? || description == ''
        ''
      else
        'Explicitation'.in_h4(class: 'libelle', style: 'margin-top: 4em') +
        humain_description.in_div(id: 'explicitation_citation')
      end
    end
  end

  def humain_description
    @humain_description ||= begin
      description.formate_balises_propres.formate_balises_erb
    end
  end

  def table
    @table ||= site.db.create_table_if_needed('site_cold', 'citations')
  end

end
