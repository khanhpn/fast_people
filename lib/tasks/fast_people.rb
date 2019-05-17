require './lib/tasks/parse_fast_people.rb'
require 'mechanize'
require 'write_xlsx'

class FastPeople
  BASE_MASTER_DATA = "#{Rails.root}/public/Book1.csv"
  BASE_MASTER_PROXY = "#{Rails.root}/public/proxy.txt"
  OUTPUT_FILE = "#{Rails.root}/public/fast_people.xlsx"
  BASE_URL = "https://www.fastpeoplesearch.com"
  DEFAULT_WEBHOOK = "https://hooks.slack.com/services/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"

  def initialize
    @rows = []
    @logger ||= Logger.new(Rails.root.join('log', "#{Time.zone.now.strftime('%d_%m_%Y_%H_%M_%S')}_fast_people.log"))
    @notifier = Slack::Notifier.new DEFAULT_WEBHOOK do
      defaults channel: "#program-khanh",
      username: "robot-crawler-fastpeople"
    end
    @workbook = WriteXLSX.new(OUTPUT_FILE)
    @worksheet = @workbook.add_worksheet
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
    # import_proxy
    MasterDatum.all.each do |item|
      @notifier.ping "#{Time.zone.now} starting craw..... with item #{item.name} #{item.zip_code} #{item.model_family}"
      @logger.info "#{Time.zone.now} starting craw..... with item #{item.name} #{item.zip_code}"
      begin
        switch_proxy(item)
      rescue Exception => e
        @logger.info "#{Time.zone.now} #{item.name}"
        @logger.fatal e.inspect
        @logger.fatal e.backtrace
        @notifier.ping "#{Time.zone.now} #{item.name}"
        @notifier.ping e.inspect
        @notifier.ping e.backtrace
      end
      @notifier.ping "#{Time.zone.now} finish craw..... with item #{item.name} #{item.zip_code}"
      @logger.info "#{Time.zone.now} finish craw..... with item #{item.name} #{item.zip_code}"
    end
    write_to_excel
  end

  def write_to_csv
    File.open(OUTPUT_FILE, "w") do |f|
      f.puts("user: {")
      User.all.each.with_index(1) do |user, index|
        f.puts("\tuser#{index}: {")
        f.puts("\t\tlink: #{user.link},")
        f.puts("\t\temails: #{eval(user.emails)},")
        f.puts("\t\twireless-phones: #{eval(user.wireless)},")
        f.puts("\t\tlandline-phones: #{eval(user.landline)},")
        f.puts("\t\tage: #{user.age}")
        f.puts("\t},")
      end
      f.puts("}")
    end
  end

  def write_to_excel
    @worksheet.write(0, 0, "ID")
    @worksheet.write(0, 1, "Name")
    @worksheet.write(0, 2, "Age")
    @worksheet.write(0, 3, "Model")
    @worksheet.write(0, 4, "Emails")
    @worksheet.write(0, 5, "Wireless")
    @worksheet.write(0, 6, "Landline")
    @worksheet.write(0, 7, "Zip Code")
    @worksheet.write(0, 8, "Zip Code Found")
    @worksheet.write(0, 9, "Link")
    User.all.each.with_index(1) do |user, index|
      emails = eval(user.emails).join(",\n")
      wireless = eval(user.wireless).join(",\n")
      landline = eval(user.landline).join(",\n")
      @worksheet.write(index, 0, "User#{index}")
      @worksheet.write(index, 1, user.name)
      @worksheet.write(index, 2, user.age)
      @worksheet.write(index, 3, user.model_family)
      @worksheet.write(index, 4, emails)
      @worksheet.write(index, 5, wireless)
      @worksheet.write(index, 6, landline)
      @worksheet.write(index, 7, user.zip_code)
      @worksheet.write(index, 8, user.zip_code)
      @worksheet.write(index, 9, user.link)
    end
    @workbook.close
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
      @notifier.ping "#{Time.zone.now} proxy expired or can't use to crawl #{name} #{port}"
      return false
    end
    true
  end

  def switch_proxy(item)
    proxy = Proxy.where(elite: true).sample
    if check_proxy?(proxy.name, proxy.port)
      obj_parse_people = ParseFastPeople.new(item.name, item.zip_code, item.model_family, @logger, proxy.name, proxy.port)
      obj_parse_people.execute
      return
    else
      proxy.update(elite: false)
      switch_proxy(item)
    end
  end
end
