# encoding: UTF-8

=begin

Pour obtenir le mail checké (si un seul):

MailMatcher::mail_found
# => Un hash avec les données du mail

Pour obtenir les mails checkés (si plusieurs)

MailMatcher::mails_found
# => Array de hash des données des mails

=end
class MailMatcher
  class << self

    attr_accessor :mail_found
    attr_accessor :mails_found

    def add_message mess
      @message_to_add ||= ""
      @message_to_add << "#{mess} "
    end
    def message_added
      @message_to_add || ""
    end
    def flush_message
      @message_to_add = nil
    end
  end
end
RSpec::Matchers::define :have_mails_with do |params|
  match do |qui|
    @qui      = qui
    @params   = params
    # Noter que ci-dessous on ne définit :to que s'il n'est pas défini
    # Cela est utile pour les procédures de destruction de l'user qui
    # empêcheraient de trouver qui.mail. Dans ces cas-là, il faut ajouter
    # la propriété `:to` aux paramètres en la renseignant avec la valeur
    # de mail qui aura été mise de côté avant.
    @params   = @params.merge(to: qui.mail) unless @params.key?(:to)
    @only_one = @params.delete(:only_one)
    # On cherche les mails
    @mails_found = search_mails_with @params
    if @only_one
      MailMatcher::mail_found = @mails_found.first
      @mails_found.count == 1
    else
      MailMatcher::mails_found = @mails_found
      @mails_found.count > 0
    end
  end
  failure_message do |qui|
    "Aucun mail n'a été trouvé avec les paramètres fournis. #{MailMatcher::message_added}"
  end
  failure_message_when_negated do |qui|
    "Des mails (@mails_found.count) ont été trouvés avec les paramètres fournis…"
  end
  description do
    if @only_one
      "Le mail spécifié a été trouvé."
    else
      "Des mails ont été trouvés."
    end
  end
end

RSpec::Matchers::define :have_mail_with do |params|
  match do |owner|
    expect(owner).to have_mails_with params.merge(:only_one => true)
  end
  failure_message do |owner|
    "Aucun mail adressé à #{params[:to]} n'a été trouvé avec les paramètres #{params.inspect}.\n#{MailMatcher::message_added}"
  end
  failure_message_when_negated do |owner|
    "Un mail a été adressé à #{params[:to]} avec les paramètres #{params.inspect}"
  end
  description do
    "Un mail a été adressé à #{params[:to]} avec les paramètres fournis."
  end
end

def search_mails_with data
  mails_found = []
  MailMatcher::flush_message

  # On répète dans tous les mails relevés
  get_mails.each do |mail|
    all_ok = true
    # On répète avec toutes les données cherchées (transmises
    # à have_mail_with)
    data.each do |k, v|
      case k
      when :subject_strict, :message_strict
        next
      when :message, :subject
        #  Si le message ou le sujet doivent être stricts
        # (message_strict / subject_strict)
        if data["#{k}_strict".to_sym] == true # => strict
          ok = mail[k] === v
        else
          v = [v] unless v.class == Array
          ok = true
          v.each do |segment|
            segment = /#{Regexp::escape segment}/ unless segment.class == Regexp
            unless mail[k].match(segment)
              ok = false
              break
            else
              MailMatcher::add_message "Segment “#{segment.to_s}” trouvé."
              ok = true
            end
          end
        end
      when :message_has_tag, :message_has_tags
        ok = true == matches_message_with_tags( mail[:message], v )
      when :message_has_not_tag, :message_has_not_tags
        ok = false == matches_message_with_tags( mail[:message], v )
      when :created_after, :sent_after
        ok = mail[:created_at] >= v
      when :created_before, :sent_before
        ok = mail[:created_at] <= v
      else
        ok = mail[k] == v
      end

      unless ok
        all_ok = false
        break
      end

    end
    mails_found << mail if all_ok
  end
  $mails_found = mails_found
  return mails_found
end
