require 'mechanize'
require 'pry'

class ParseFastPeople
  BASE_URL_TEST = "https://www.fastpeoplesearch.com/mary-anne-rabon_id_G-6962601656597233420"
  BASE_URL = "https://www.fastpeoplesearch.com"
  PHONE_WIRELESS = "wireless-phones"
  PHONE_LANDLINE = "landline-phones"

  attr_accessor :name, :zip_code, :log
  def initialize(name, zip_code, log)
    @mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.set_proxy '137.53.216.209', 443
    }
    @name = convert_name(name)
    @zip_code = convert_zip_code(zip_code)
    @page = nil
    @log = log
  end

  def execute
    link = parse_search_result
    @log.info "#{Time.zone.now} #{link}"
    return unless link.present?
    @page = @mechanize.get(link)
    phones = get_phones
    {
      "age" => get_age, "emails" => get_emails, "wireless-phones" => phones.get_values(:wireless).compact,
      "landline-phones" => phones.get_values(:landline).compact
    }
  end

  # i will get the first link which it match
  # go to the search page and get the first link in these links the engine returned
  # input: name and zipcode
  # output: link detail base on name and zipcode
  def parse_search_result
    links = []
    url = "#{BASE_URL}/name/#{@name}_#{@zip_code}"
    @page = @mechanize.get(url)
    parse_detail_link = @page.search("//a[@class='btn btn-primary link-to-details']")
    if parse_detail_link.present?
      parse_detail_link.each do |item|
        begin
          next unless item.present?
          raw_link = item.attributes["href"]&.value
          @log.info "#{Time.zone.now} #{raw_link}"
          links << "#{BASE_URL}#{raw_link}" if raw_link.present?
        rescue e
          @log.info "#{Time.zone.now} #{@name} #{@zip_code} #{item}"
          @log.fatal e.inspect
          @log.fatal e.backtrace
        end
      end
    end
    links.first
  end

  private
  def get_age
    age = @page.search(".//h1/span")
    begin
      age = age.text.strip
      return age.split(" ").dig(1)
    rescue e
      @log.info "#{Time.zone.now} #{@name} #{@zip_code}"
      @log.fatal e.inspect
      @log.fatal e.backtrace
    end
    nil
  end

  def get_phones
    phones = []
    parse_phones = @page.search(".//div[@class='detail-box-phone']/p")
    parse_phones.each do |item|
      begin
        if item.present? && item.content.present?
          phone_content = item.content
          phone = item.search("a")[0].text
          phones << {"landline": phone} if phone_content&.downcase.include?("landline")
          phones << {"wireless": phone} if phone_content&.downcase.include?("wireless")
        end
      rescue e
        @log.info "#{Time.zone.now} #{@name} #{@zip_code} #{item}"
        @log.fatal e.inspect
        @log.fatal e.backtrace
      end
    end

    more_phones = @page.search(".//div[@id='collapsed-phones']/p")
    if more_phones
      more_phones.each do |item|
        begin
          phone_content = item.content
          phone = item.search("a")[0].text
          phones << {"landline": phone} if phone_content&.downcase.include?("landline")
          phones << {"wireless": phone} if phone_content&.downcase.include?("wireless")
        rescue e
          @log.info "#{Time.zone.now} #{@name} #{@zip_code} #{item}"
          @log.fatal e.inspect
          @log.fatal e.backtrace
        end
      end
    end
    phones
  end

  def get_emails
    emails = []
    parse_emails = @page.search(".//div[@class='detail-box-email']")
    protected_emails = parse_emails[0].search("a")
    protected_emails.each do |item|
      begin
        next if item.attributes["data-cfemail"].nil?
        emails << cfDecodeEmail(item.attributes["data-cfemail"].value)
      rescue e
        @log.info "#{Time.zone.now} #{@name} #{@zip_code}"
        @log.fatal e.inspect
        @log.fatal e.backtrace
      end
    end

    more_emails = @page.search(".//div[@id='collapsed-emails']/p")
    if more_emails.present?
      begin
        more_emails[0].search("a").each do |item|
          begin
            next if item.attributes["data-cfemail"].nil?
            emails << cfDecodeEmail(item.attributes["data-cfemail"].value)
          rescue e
            @log.info "#{Time.zone.now} #{@name} #{@zip_code} #{item}"
            @log.fatal e.inspect
            @log.fatal e.backtrace
          end
        end
      rescue e
        @log.info "#{Time.zone.now} #{@name} #{@zip_code}"
        @log.fatal e.inspect
        @log.fatal e.backtrace
      end
    end
    emails
  end

  private
  def cfDecodeEmail(encodedString)
    k = encodedString[0..1]
    k = k.to_i(16).to_s(10)

    email = ''
    newEncodedString = encodedString[2..-1]
    newEncodedString.split("").each_slice(2) do |a, b|
    pairing = a + b
    pairing = pairing.to_i(16).to_s
    pairing = eval(pairing)^eval(k)
    pairing = pairing.chr
    email << pairing
    end
    return email
  end

  def cf_decode_email(str)
    encoded = [str].pack("H*").bytes
    key = encoded.shift
    decoded = encoded.collect { |x| x ^ key }
    decoded.pack('c*')
  end

  # convert text to underscore
  # Some Text Here -> some_text_here
  def convert_name(name)
    name.split(" ").map(&:downcase).join("-")
  end

  def convert_zip_code(zip_code)
    zip_code.split("-").join("~")
  end
end
