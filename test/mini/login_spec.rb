# encoding: UTF-8
=begin
Test du login
=end

require './data/secret/data_phil'
dform = {
  user_mail:      DATA_PHIL[:mail],
  user_password:  DATA_PHIL[:password]
}
test_form "user/login", dform do |f|

  f.exist
  f.fill(submit: true)
  f.has_message "Bievenue Phil !"

end
