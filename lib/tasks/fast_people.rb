require './lib/tasks/parse_fast_people.rb'
require 'mechanize'
require 'write_xlsx'

class FastPeople
  BASE_MASTER_DATA = "#{Rails.root}/public/Book1.csv"
  BASE_MASTER_PROXY = "#{Rails.root}/public/proxy.txt"
  BASE_URL = "https://www.fastpeoplesearch.com"
  DEFAULT_WEBHOOK = "https://hooks.slack.com/services/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"
  MAXROWS = 5000

  def initialize
    @rows = []
    @logger ||= Logger.new(Rails.root.join('log', "#{Time.zone.now.strftime('%d_%m_%Y_%H_%M_%S')}_fast_people.log"))
    @notifier = Slack::Notifier.new DEFAULT_WEBHOOK do
      defaults channel: "#program-khanh",
      username: "robot-crawler-fastpeople"
    end
  end

  def import_zipcode_file
    puts "#{Time.zone.now} starting import master data to database"
    File.open(BASE_MASTER_DATA).each_with_index do |row, index|
      next if index == 0
      item = row.squish.split(",")
      master_data = MasterDatum.where(
        id_user_info: item.dig(0).squish,
        model_family: item.dig(1).squish,
        name: item.dig(2).squish,
        zip_code: item.dig(3).squish
      )
      if !master_data.present?
        MasterDatum.create({
          id_user_info: item.dig(0).squish,
          model_family: item.dig(1).squish,
          name: item.dig(2).squish,
          zip_code: item.dig(3).squish
        })
        puts "#{Time.zone.now} importing #{item.dig(0)}"
      end
    end
    puts "#{Time.zone.now} finished import master data to database"
  end

  def execute
    # import_zipcode_file
    @notifier.ping "#{Time.zone.now} beginning start robot crawler.........."
    MasterDatum.all.each.with_index(0) do |item, index|
      @logger.info "#{Time.zone.now} starting craw..... with item #{item.name} #{item.zip_code}"
      begin
        switch_proxy(item)
      rescue Exception => e
        @logger.info "#{Time.zone.now} #{item.name}"
        @logger.fatal e.inspect
        @logger.fatal e.backtrace
      end
      @logger.info "#{Time.zone.now} finish craw..... with item #{item.name} #{item.zip_code}"
    end
    @notifier.ping "#{Time.zone.now} finished robot crawler.........., waiting some seconds to export excel"
    create_new_excel
  end

  def create_new_excel
    output_file = "#{Rails.root}/public/fast_people.xlsx"
    workbook = WriteXLSX.new(output_file)
    worksheet = workbook.add_worksheet
    write_to_excel(worksheet, workbook)
  end

  def write_to_excel(worksheet, workbook)
    worksheet.write(0, 0, "ID")
    worksheet.write(0, 1, "Name")
    worksheet.write(0, 2, "Age")
    worksheet.write(0, 3, "Model")
    worksheet.write(0, 4, "Emails")
    worksheet.write(0, 5, "Wireless")
    worksheet.write(0, 6, "Landline")
    worksheet.write(0, 7, "Zip Code")
    worksheet.write(0, 8, "Zip Code Found")
    worksheet.write(0, 9, "Link")
    User.where(is_checked: true).each.with_index(1) do |user, index|
      emails = eval(user.emails).join(",\n")
      wireless = eval(user.wireless).join(",\n")
      landline = eval(user.landline).join(",\n")
      worksheet.write(index, 0, user.id_user_info)
      worksheet.write(index, 1, user.name)
      worksheet.write(index, 2, user.age)
      worksheet.write(index, 3, user.model_family)
      worksheet.write(index, 4, emails)
      worksheet.write(index, 5, wireless)
      worksheet.write(index, 6, landline)
      worksheet.write(index, 7, user.zip_code)
      worksheet.write(index, 8, user.zip_code)
      worksheet.write(index, 9, user.link)
    end
    write_error_links(worksheet, workbook)
  end

  def write_error_links(worksheet, workbook)
    worksheet = workbook.add_worksheet
    worksheet.write(0, 0, "ID")
    worksheet.write(0, 1, "Model")
    worksheet.write(0, 2, "Name")
    worksheet.write(0, 3, "Zip Code")
    worksheet.write(0, 4, "Link")
    worksheet.write(0, 5, "Error")
    ErrorUser.all.each.with_index(1) do |user, index|
      worksheet.write(index, 0, user.id_user_info)
      worksheet.write(index, 1, user.model_family)
      worksheet.write(index, 2, user.name)
      worksheet.write(index, 3, user.zip_code)
      worksheet.write(index, 4, user.link)
      worksheet.write(index, 5, user.error)
    end
    workbook.close
    User.update_all(is_checked: false)
    @notifier.ping "#{Time.zone.now} finished to export excel, please go to public folder to get file, thank you"
  end

  private

  def switch_proxy(item)
    begin
      @logger.info "#{Time.zone.now} start crawl again #{item.name}"
      obj_parse_people = ParseFastPeople.new(
        item.id_user_info,
        item.name, item.zip_code, item.model_family,
        @logger
      )
      obj_parse_people.execute
    rescue Exception => e
      switch_proxy(item)
      @logger.info "#{Time.zone.now} #{item.name}"
      @logger.info "#{Time.zone.now} crawl #{item.name} again"
      @logger.fatal e.inspect
      @logger.fatal e.backtrace
    end
  end
end
