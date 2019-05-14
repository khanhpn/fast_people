require './lib/tasks/parse_fast_people.rb'

class FastPeople
  BASE_MASTER_DATA = "#{Rails.root}/public/Book1.csv"
  BASE_MASTER_PROXY = "#{Rails.root}/public/proxy.txt"
  OUTPUT_FILE = "#{Rails.root}/public/fast_people.csv"

  def initialize
    @rows = []
  end

  def read_zipcode_file
    puts "#{Time.zone.now} starting import master data to database"
    File.open(BASE_MASTER_DATA).each_with_index do |row, index|
      next if index == 0
      item = row.squish.split(",")
      master_data = MasterDatum.where(model_family: item.dig(0), name: item.dig(1), zip_code: item.dig(2))
      if !master_data.present?
        MasterDatum.create({model_family: item.dig(0), name: item.dig(1), zip_code: item.dig(2)})
        puts "#{Time.zone.now} importing #{item.dig(0)}"
      end
    end
    puts "#{Time.zone.now} finished import master data to database"

    @rows = [
      user1: {
        emails: ["a@gmail.com", "a@gmail.com"],
        "wireless-phones": ["1", "2", "3"],
        "landline-phones": ["1", "2", "3"],
        age: 1
      },
      user2: {
        emails: ["a@gmail.com", "a@gmail.com"],
        "wireless-phones": ["1", "2", "3"],
        "landline-phones": ["1", "2", "3"],
        age: 1
      },
      user3: {
        emails: ["a@gmail.com", "a@gmail.com"],
        "wireless-phones": ["1", "2", "3"],
        "landline-phones": ["1", "2", "3"],
        age: 1
      },
      user4: {
        emails: ["a@gmail.com", "a@gmail.com"],
        "wireless-phones": ["1", "2", "3"],
        "landline-phones": ["1", "2", "3"],
        age: 1
      }
    ]
  end

  def execute
    read_zipcode_file
    obj_parse_people = ParseFastPeople.new
    obj_parse_people.execute
    write_to_csv
  end

  def write_to_csv
    File.open(OUTPUT_FILE, "w") do |f|
      @rows.each do |row|
        f.puts(row)
        f.write "\n"
      end
    end
  end
end
