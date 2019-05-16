require './lib/tasks/fast_people.rb'

namespace :crawl_fast_people do
  desc 'starting crawl data from fastpeople'
  task start: :environment do
    MasterDatum.destroy_all
    fast_people = FastPeople.new
    fast_people.execute
  end
end
