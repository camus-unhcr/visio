server = '10.9.43.173'

role :web, server
role :app, server                          # This may be the same as your `Web` server
role :db,  server, :primary => true # This is where Rails migrations will run
role :resque_worker, server
