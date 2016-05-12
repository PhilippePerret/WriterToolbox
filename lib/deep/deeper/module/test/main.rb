# encoding: UTF-8
=begin
Essai pour des tests particuliers
=end
def log mess
  SiteHtml::Test::log mess
end
class SiteHtml
class Test
  class << self

    attr_reader :failures
    attr_reader :success

    def log mess; console.sub_log mess end

    # Jouer la suite de tests
    def run options = nil
      options = parse_options options
      @failures = Array::new
      @success  = Array::new
      Dir["./test/**/*_spec.rb"].each do |p|
        new(p).execute
      end
      display_resultat
      return "" # pour la console
    end

    def display_resultat
      log resultat
    end

    def resultat
      @resultat ||= begin
        color = failures.empty? ? 'green' : 'red'
        s_failures = nombre_failures > 1 ? "s" : ""
        resume = "#{nombre_failures} failure#{s_failures} #{nombre_success} succès".in_span(class: color)

        (
          resume +
          detail_failures +
          detail_success
        )
      end
    end
    def nombre_failures; @nombre_failures ||= failures.count  end
    def nombre_success;   @nombre_succes  ||= success.count   end

    def detail_failures
      return "" if nombre_failures == 0
      failures.collect do |itest, test_name, erreur|
        (
          test_name.in_div(class:'tname err') +
          "File: #{itest.path}".in_div(class:'pfile') +
          erreur.to_s.in_div(class:'mess')
        ).in_div(class:'atest err')
      end.join("\n")
    end
    def detail_success
      return "" if nombre_success == 0
      "Succès".in_h3 +
      success.collect do |itest, test_name, notice|
        (
          test_name.in_div(class:'tname suc') +
          "File: #{itest.path}".in_div(class:'pfile') +
          notice.to_s.in_div(class:'mess')
        ).in_div(class:'atest suc')
      end.join("\n")
    end

    def parse_options options
      options ||= Hash::new

      options
    end

    def add_failure itest, test_name, message
      @failures << [itest, test_name, message]
    end
    def add_success itest, test_name, message
      @success << [itest, test_name, message]
    end
  end #/<<self
end #/SiteHtml
end #/Test
