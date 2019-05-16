require './lib/tasks/parse_fast_people.rb'
require 'mechanize'

class FastPeople
  BASE_MASTER_DATA = "#{Rails.root}/public/Book1.csv"
  BASE_MASTER_PROXY = "#{Rails.root}/public/proxy.txt"
  OUTPUT_FILE = "#{Rails.root}/public/fast_people.json"
  BASE_URL = "https://www.fastpeoplesearch.com"

  def initialize
    @rows = []
    @logger ||= Logger.new(Rails.root.join('log', 'fast_people.log'))
  end

  def import_zipcode_file
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

  def import_proxy
    puts "#{Time.zone.now} starting import proxy"
    File.open(BASE_MASTER_PROXY).each do |row|
      raw_row = row.split(":")
      name = raw_row.dig(1)
      port = raw_row.dig(2).to_i
      proxy = Proxy.where(name: name, port: port)
      expired_proxy = Proxy.where(elite: false)
      expired_proxy.destroy_all if expired_proxy.present?
      next if proxy.present? || !check_proxy?(name, port)
      puts "#{Time.zone.now} importing #{row}"
      Proxy.create({name: name, port: port, elite: true})
    end
    puts "#{Time.zone.now} finish import proxy"
  end

  def execute
    import_zipcode_file
    import_proxy
    MasterDatum.all.each do |item|
      @logger.info "#{Time.zone.now} starting craw..... with item #{item.name} #{item.zip_code}"
      switch_proxy(item)
      @logger.info "#{Time.zone.now} finish craw..... with item #{item.name} #{item.zip_code}"
    end
    write_to_csv
  end

  def write_to_csv
    File.open(OUTPUT_FILE, "w") do |f|
      f.puts("user: {")
      @rows.each.with_index(1) do |row, index|
        f.puts("\tuser#{index}: {")
        f.puts("\t\tlink: #{row['link']},")
        f.puts("\t\temails: #{row['emails']},")
        f.puts("\t\twireless-phones: #{row['wireless-phones']},")
        f.puts("\t\tlandline-phones: #{row['landline-phones']},")
        f.puts("\t\tage: #{row['age']},")
        f.puts("\t},")
      end
      f.puts("}")
    end
  end

  private
  def check_proxy?(name, port)
    mechanize = Mechanize.new {|agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.set_proxy name, port
    }
    begin
      mechanize.get(BASE_URL)
    rescue Exception => e
      return false
    end
    true
  end

  def switch_proxy(item)
    proxy = Proxy.where(elite: true).sample
    if check_proxy?(proxy.name, proxy.port)
      obj_parse_people = ParseFastPeople.new(item.name, item.zip_code, @logger, proxy.name, proxy.port)
      @rows << obj_parse_people.execute
      return
    else
      proxy.update(elite: false)
      switch_proxy(item)
    end
  end
end
