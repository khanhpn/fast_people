require './lib/tasks/parse_fast_people.rb'

class FastPeople
  BASE_MASTER_DATA = "#{Rails.root}/public/Book1.csv"
  BASE_MASTER_PROXY = "#{Rails.root}/public/proxy.txt"
  OUTPUT_FILE = "#{Rails.root}/public/fast_people.json"

  def initialize
    @rows = []
    @logger ||= Logger.new(Rails.root.join('log', 'fast_people.log'))
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
  end

  def execute
    read_zipcode_file
    MasterDatum.all.each do |item|
      obj_parse_people = ParseFastPeople.new(item.name, item.zip_code, @logger)
      @rows << obj_parse_people.execute
    end
    write_to_csv
  end

  def write_to_csv
    File.open(OUTPUT_FILE, "w") do |f|
      f.puts("user: {")
      @rows.each.with_index(1) do |row, index|
        f.puts("\tuser#{index}: {")
        f.puts("\t\temails: #{row['emails']},")
        f.puts("\t\twireless-phones: #{row['wireless-phones']},")
        f.puts("\t\tlandline-phones: #{row['landline-phones']},")
        f.puts("\t\tage: #{row['age']},")
        f.puts("\t}")
      end
      f.puts("}")
    end
  end
end
