# encoding: UTF-8
class SyncRestsite

  APPLICATIONS = {
    icare: {
      hname:        'Atelier Icare',
      path:         '/Users/philippeperret/Sites/AlwaysData/Icare_AD_2016',
      folders_out:  [
        '_Dev_', 'CRON', 'database', 'data', 'tmp', 'spec', 'hot',
        'lib/app', 'objet',
        'view/gabarit',
        'xprev_version'
      ],
      folders_in: [
      ],
      files_out: [
        'index.rb',
        'lib/deep/deeper/module/paiement/transaction.rb',
        'lib/preambule.rb',
        'README.md',
        'objet/site/config.rb',
        'objet/admin/dashboard.rb',
        'objet/admin/lib/module/sync/synchronisation/page_comments.rb',
        'objet/admin/lib/required/constants.rb',
        'objet/admin/mailing.rb',
        'objet/site/home.rb',
        'objet/site/data_synchro.rb',
        'objet/site/contact.rb',
        'lib/deep/deeper/required/User/instance/search_engines.rb',
        'lib/deep/deeper/required/Page/html.rb',
        'lib/deep/deeper/required/Site/config.rb',
        'lib/deep/deeper/required/Site/data.rb',
        'lib/deep/deeper/required/Site/handy.rb',
        'lib/deep/deeper/required/User/class/database.rb'
      ]
    },
    boa: {
      hname: 'Boite à outils',
      path: '/Users/philippeperret/Sites/WriterToolbox',
      folders_out: [
        '_Dev_', 'CRON2', 'database', 'data', 'tmp', 'spec', 'hot',
        'lib/app', 'objet',
        'view/gabarit'
      ],
      files_out: [
        'index.rb',
        'lib/deep/deeper/module/mail/mail.rb',
        'lib/deep/deeper/module/paiement/transaction.rb',
        'lib/deep/deeper/module/synchronisation/synchronisation/required/debug.rb',
        'lib/preambule.rb',
        'README.md',
        'objet/site/config.rb',
        'objet/admin/dashboard.rb',
        'objet/admin/lib/required/constants.rb',
        'objet/admin/mailing.rb',
        'objet/site/points_abonnement.rb',
        'objet/site/points_abonnement.erb',
        'objet/site/home.rb',
        'objet/site/data_synchro.rb',
        'objet/site/contact.rb',
        'lib/deep/deeper/required/User/instance/search_engines.rb',
        'lib/deep/deeper/required/Page/html.rb',
        'lib/deep/deeper/required/Site/config.rb',
        'lib/deep/deeper/required/Site/data.rb',
        'lib/deep/deeper/required/Site/handy.rb',
        'lib/deep/deeper/required/User/class/database.rb'
      ],
      folders_in: [
      ]
    }
  }

end #/SyncRestsite
