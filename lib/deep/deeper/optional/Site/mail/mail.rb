# encoding: UTF-8

require 'cgi'
require 'net/smtp'

class SiteHtml

  # Envoi d'un mail
  # @usage
  #   site.send_mail({
  #     to:     <mail receveur>,
  #     from:   <mail expéditeur>,
  #     subject:  "<le sujet>",
  #     message:  "<le message>"
  #   })
  #
  def exec_send_mail data_mail
    # debug "data mail :#{data_mail}"
    Mail::new(data_mail).send
  rescue Exception => e
    error e.message
  else
    true # pour confirmer que l'envoi a pu se faire
  end
end

# Pour le moment, on met ce module ici, mais il devra être
# mis dans un fichier si on a besoin de le charger ailleurs.
# Sur l'atelier il était dans un fichier séparé car le CRON-JOB
# en avait besoin
module MailModuleMethods
  # Initialize a new mail
  #
  # * PARAMS
  #   :data::     Provided data
  #               :from::           Sender
  #               :to::             Receiver
  #               :subject::        Subject of the mail
  #               :message::        Code of the message to send
  #               :force_offline    Si TRUE, envoie même en offline
  #               :formated         Si TRUE, le message est considéré comme
  #                                 formaté
  #               :format::         Si :text, le message est laissé en code
  #                                 brut (pas HTML)
  #               :data::           Data to use with type-messages. Every
  #                                 key will be turn into its value.
  #
  def initialize data = nil
    @data = data
    data.each do |k,v|
      v = case v
      when FalseClass, TrueClass, Fixnum then v
      else v.nil_if_empty
      end
      instance_variable_set("@#{k}", v)
    end unless data.nil?
  end

  # ---------------------------------------------------------------------
  #   Méthode de définition et de récupération des variables volatiles
  #   de classe. Permet de définir des variables qui n'ont pas besoin
  #   d'être recalculées pour chaque mail
  # ---------------------------------------------------------------------
  def set_class key, value
    self.class.instance_variable_set("@#{key}", value)
  end
  def get_class key
    self.class.instance_variable_get("@#{key}")
  end


  # ---------------------------------------------------------------------
  # Le message complet final
  # ------------------------
  def message
    "From: <#{from}>\nTo: <#{to}>\nMIME-Version: 1.0\nContent-type: text/html; charset=UTF-8\nSubject: #{subject}\n\n#{code_html}"
  end

  # ----------------------------------------------------------------------
  #   Sous-méthode de construction du message

  def from; @from ||= site.mail end
  def to  ; @to   ||= site.mail end

  def code_html
    @code_html ||= <<-HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html><head>#{content_type}#{title}#{style_tag}</head><body>#{body}</body></html>
    HTML
  end

  # / Sous-méthode de construction du message
  # ---------------------------------------------------------------------


  # ---------------------------------------------------------------------
  #   Sous-sous-méthodes de construction du message

  # Pour la balise title du message HTML
  def title
    @title ||= "<title>#{subject}</title>"
  end
  # Pour le sujet du message
  def subject
    @subject ||= "(sans sujet)"
    "#{header_subject}#{@subject}"
  end
  def content_type
    if get_class(:content_type).nil?
      set_class(:content_type, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>')
    end
    get_class(:content_type)
  end

  # Le corps du message du mail
  def body
    c = "#{header}<div id='message_content'>#{ message_formated + signature + footer }</div>"
    # Si le body style est défini, on met le code dans un div
    # contenant ce body style.
    c = c.in_div(style: SiteHtml::Mail::body_style) if SiteHtml::Mail::respond_to?(:body_style)
    return c
  end

  def style_tag
    if get_class(:style_tag).nil?
      stag = ""
      stag << "body{#{SiteHtml::Mail::body_style}}"  if SiteHtml::Mail::respond_to?(:body_style)
      stag << SiteHtml::Mail::styles_css             if SiteHtml::Mail::respond_to?(:styles_css)
      set_class(:style_tag, "<style type='text/css'>#{stag}</style>")
    end
    get_class(:style_tag)
  end

  # / Sous-sous-méthodes
  # ---------------------------------------------------------------------

  # ---------------------------------------------------------------------
  #   Sous-sous-sous méthodes de construction du message


  def header
    if get_class(:header).nil?
      set_class(:header, SiteHtml::Mail::respond_to?(:header) ? SiteHtml::Mail::header : "" )
    end
    get_class :header
  end

  def header_subject
    if get_class(:header_subject).nil?
      set_class(:header_subject, site.mail_before_subject ? "#{site.mail_before_subject} " : "" )
    end
    get_class :header_subject
  end

  def signature
    set_class(:signature, site.mail_signature ? site.mail_signature : "") if get_class(:signature).nil?
    get_class :signature
  end

  def footer
    set_class(:footer, SiteHtml::Mail::respond_to?(:footer) ? SiteHtml::Mail::footer : "") if get_class(:footer).nil?
    get_class :footer
  end


  # ---------------------------------------------------------------------
  #   Sous-sous-sous-sous méthodes de construction du message

  def message_formated
    return @message if already_formarted?
    c = @message
    if return_to_br_in_message?
      if c.match("\n")
        c.gsub!(/\n/, '<br>')
        c.gsub!(/\r/, '')
      elsif c.match("\r")
        c.gsub!(/\r/, '<br>')
        c.gsub!(/\n/, '')
      end
    end
    "<div>#{c}</div>"
  end


  # ---------------------------------------------------------------------
  #   Méthode d'état ou fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne true si le message est formaté HTML
  def already_formarted?
    @formated == true || @message.match(/(<div |<p )/)
  end

  # Return true s'il faut corriger les retours de chariot et
  # les remplacer par des <br>
  # Note : Seulement si le message doit être formaté
  def return_to_br_in_message?
    if defined? CORRECT_RETURN_IN_MESSAGE
      CORRECT_RETURN_IN_MESSAGE
    else
      true
    end
  end
end # /fin module MailModuleMethods

class SiteHtml
  class Mail
    include MailModuleMethods

    # Les données SMTP pour l'envoi des mails
    require File.join('.', 'data', 'secret', 'data_mail.rb')

    # -------------------------------------------------------------------
    #   Classe
    # -------------------------------------------------------------------

    class << self

      # Send the mail (don't call directly, use Mail.new(...) instead)
      #
      # * PARAMS
      #   :mail::       Formated mail code
      #   :to::         Email address of the receiver
      #   :from::       Email address of the sender (me by default)
      #
      def send mail, to, from
        Net::SMTP.start(
          MY_SMTP[:server],
          MY_SMTP[:port],
          'localhost',      # serveur From (sera à régler plus tard suivant
                            # online/offline)
          MY_SMTP[:user],
          MY_SMTP[:password]
          ) do |smtp|
            smtp.send_message mail, from, to
        end
      end

      def online?
        @is_online ||= begin
          (ENV['HTTP_HOST'] != nil && ENV['HTTP_HOST'] != 'localhost' && ENV['HTTP_HOST'] != '127.0.0.1')
        end
      end
      def offline?
        @is_offline ||= !online?
      end

    end # /<< self

    # -------------------------------------------------------------------
    #   Instance
    # -------------------------------------------------------------------

    # Données transmises à l'instanciation
    attr_reader :data

    # Mail format (:html, :text, :both)
    attr_reader :format

    # Envoi du message
    # ----------------
    def send
      if self.class.offline? && ( @force_offline != true ) && self.class.respond_to?(:send_offline)
        self.class.send_offline data.merge(subject: subject, to: to, from: from, message: message)
      else
        self.class.send message, to, from
      end
    end

  end
end
