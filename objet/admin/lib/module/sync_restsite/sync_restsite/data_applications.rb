# encoding: UTF-8
class SyncRestsite

  APPLICATIONS = {
    icare: {
      hname:        'Atelier Icare',
      path:         '/Users/philippeperret/Sites/AlwaysData/Icare_AD_2016',
      folders_out:  [
        '_Dev_', 'CRON', 'database', 'data', 'tmp', 'spec', 'hot',
        'lib/app', 'objet',
        'xprev_version'
      ],
      folders_in: [
        'objet/site', 'objet/admin'
      ],
      files_out: ['index.rb']
    },
    boa: {
      hname: 'Boite à outils',
      path: '/Users/philippeperret/Sites/WriterToolbox',
      folders_out: [
        '_Dev_', 'CRON2', 'database', 'data', 'tmp', 'spec', 'hot',
        'lib/app', 'objet'
      ],
      files_out: [
        'index.rb',
        'lib/deep/deeper/module/mail/mail.rb'
      ],
      folders_in: [
        'objet/site', 'objet/admin'
      ]
    }
  }

end #/SyncRestsite
