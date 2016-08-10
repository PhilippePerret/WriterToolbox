# encoding: UTF-8
=begin

  Méthodes
  --------

    User#a_recu_un_mail <data_mail>
    User#napas_recu_un_mail <data mail>
    User#napas_recu_de_mail

=end
class User
  def a_recu_le_mail dmail
    mess_succ = dmail.delete(:success) || "#{pseudo} a reçu un mail avec les paramètres fournis."
    dmail.merge!(to: self.mail)
    MailMatcher.search_mails_with dmail
    nombre_mails = MailMatcher.mails_found.count
    if nombre_mails > 0
      success mess_succ
    else
      raise "#{pseudo} n'a reçu aucun mail correspondant aux paramètres demandés."
    end
  end
  def napas_recu_le_mail dmail
    mess_succ = dmail.delete(:success) || "#{pseudo} n'a reçu aucun mail avec les paramètres fournis."
    dmail.merge!(to: self.mail)
    MailMatcher.search_mails_with dmail
    nombre_mails = MailMatcher.mails_found.count
    if nombre_mails == 0
      success mess_succ
    else
      raise "#{pseudo} a malheureusement reçu un mail correspondant aux paramètres demandés."
    end
  end
  def napas_recu_de_mail
    mails = MailMatcher.search_mails_with(to: self.mail)
    if mails.count == 0
      success "#{pseudo} n'a reçu aucun mail."
    else
      raise "#{pseudo} n'aurait dû recevoir aucun mail."
    end
  end
end
