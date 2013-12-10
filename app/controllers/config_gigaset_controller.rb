class ConfigGigasetController < ApplicationController

  MAX_SIP_ACCOUNTS = 6
  MAX_HANDSETS = 4

  before_filter {
    @mac_address = params[:mac_address].to_s.upcase.gsub(/[^0-9A-F]/,'')
    @provisioning_key = params[:provisioning_key].to_s
    @build_variant = params[:build_variant].to_i
    @provisioning_id = params[:provisioning_id].to_i
  }

  def show
    if @mac_address
      @phone = Phone.where(:mac_address => @mac_address).first
    end

    if ! @phone
      render(
        :status => 404,
        :layout => false,
        :content_type => 'text/plain',
        :text => "<!-- Phone not found -->",
      )
      return false
    end

    @profile_name = 'GS5'

    config_changed = [@phone.updated_at]
    @phone.phone_sip_accounts.each do |phone_sip_account|
      config_changed << phone_sip_account.updated_at
    end
    #@config_version = Time.now.utc.strftime('%d%m%y%H%M')

=begin
    countries_map = {
      => 0, # Albania
      => 1, # Argentina
      => 2, # Australia
      => 3, # Austria
      => 4, # Bahrain
      => 5, # Belarus
      => 6, # Belgium
      => 7, # Bolivia
      => 8, # Bosnia and Herzegovina
      => 9, # Brazil
      => 10, # Bulgaria
      => 11, # Canada
      => 12, # Chile
      => 13, # China
      => 14, # Colombia
      => 15, # Costa Rica
      => 16, # Croatia
      => 17, # Cyprus
      => 18, # Czech Republic
      => 19, # Denmark
      => 20, # Ecuador
      => 21, # Egypt
      => 22, # Estonia
      => 23, # Finland
      => 24, # France
      => 25, # Germany
      => 26, # Greece
      => 27, # Hong Kong
      => 28, # Hungary
      => 29, # Iceland
      => 30, # India
      => 31, # Indonesia
      => 32, # Ireland
      => 33, # Israel
      => 34, # Italy
      => 35, # Japan
      => 36, # Jordan
      => 37, # Korea, Republic of
      => 38, # Kuwait
      => 39, # Latvia
      => 40, # Lebanon
      => 41, # Liechtenstein
      => 42, # Lithuania
      => 43, # Luxembourg
      => 44, # Macedonia
      => 45, # Malaysia
      => 46, # Mexico
      => 47, # Morocco
      => 48, # Netherlands
      => 49, # New Zealand
      => 50, # Norway
      => 51, # Pakistan
      => 52, # Panama
      => 53, # Paraguay
      => 54, # Peru
      => 55, # Philippines
      => 56, # Poland
      => 57, # Portugal
      => 58, # Puerto
      => 59, # Romania
      => 60, # Russia
      => 61, # Saudi Arabia
      => 62, # Serbia
      => 63, # Singapore
      => 64, # Slovakia
      => 65, # Slovenia
      => 66, # South Africa
      => 67, # Spain
      => 68, # Sweden
      => 69, # Switzerland
      => 70, # Taiwan
      => 71, # Thailand
      => 72, # Turkey
      => 73, # United Arab Emirates
      => 74, # United Kingdom
      => 75, # United States of America
      => 76, # Uruguay
      => 77, # Venezuela
      => 78, # Other Country
      => 79, # Namibia
      => 80, # Palestine
      => 81, # Montenegro
      => 82, # Iran
      nil => 255, # undefined
    }

    time_zones_map = {
      => 0, # -12:00 - International Date Line West
      => 1, # -11:00 - Midway Island, Samoa
      => 2, # -10:00 - Hawaii
      => 3, # -09:00 - Alaska
      => 4, # -08:00 - Pacific Time (US and Canada), Tijuana
      => 5, # -07:00 - Arizona
      => 6, # -07:00 - Chihuahua, La Paz, Mazatlan
      => 7, # -07:00 - Mountain Time (US and Canada) 
      => 8, # -06:00 - Central America 
      => 9, # -06:00 - Central Time (US and Canada)
      => 10, # -06:00 - Guadalajara, Mexico City, Monterrey 
      => 11, # -06:00 - Saskatchewan 
      => 12, # -05:00 - Bogota, Lima, Quito 
      => 13, # -05:00 - Eastern Time (US and Canada) 
      => 14, # -05:00 - Indiana (East) 
      => 15, # -04:00 - Atlantic Time (Canada) 
      => 16, # -04:00 - Caracas, La Paz 
      => 17, # -04:00 - Santiago 
      => 18, # -03:30 - Newfoundland 
      => 19, # -03:00 - Brasilia 
      => 20, # -03:00 - Buenos Aires, Georgetown 
      => 21, # -03:00 - Greenland 
      => 22, # -02:00 - Mid-Atlantic 
      => 23, # -01:00 - Azores 
      => 24, # -01:00 - Cape Verde Is. 
      => 25, # 00:00 - Casablanca, Monrovia
      => 26, # 00:00 - Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London 
      => 27, # +01:00 - Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna 
      => 28, # +01:00 - Belgrade, Bratislava, Budapest, Ljubljana, Prague 
      => 29, # +01:00 - Brussels, Copenhagen, Madrid, Paris 
      => 30, # +01:00 - Sarajevo, Skopje, Warsaw, Zagreb  
      => 31, # +01:00 - West Central Africa 
      => 32, # +02:00 - Athens, Beirut, Istanbul, Minsk 
      => 33, # +02:00 - Bucharest 
      => 34, # +02:00 - Cairo 
      => 35, # +02:00 - Harare, Pretoria 
      => 36, # +02:00 - Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius 
      => 37, # +02:00 - Jerusalem 
      => 38, # +03:00 - Baghdad 
      => 39, # +03:00 - Kuwait, Riyadh 
      => 40, # +03:00 - Moscow, St. Petersburg, Volgograd 
      => 41, # +03:00 - Nairobi 
      => 42, # +03:30 - Tehran 
      => 43, # +04:00 - Abu Dhabi, Muscat 
      => 44, # +04:00 - Baku, Tbilisi, Yerevan 
      => 45, # +04:30 - Kabul  
      => 46, # +05:00 - Ekaterinburg  
      => 47, # +05:00 - Islamabad, Karachi, Tashkent 
      => 48, # +05:30 - Chennai, Kolkata, Mumbai, New Delhi  
      => 49, # +05:45 - Kathmandu 
      => 50, # +06:00 - Almaty, Novosibirsk 
      => 51, # +06:00 - Astana, Dhaka  
      => 52, # +06:00 - Sri Jayawardenepura  
      => 53, # +06:30 - Rangoon 
      => 54, # +07:00 - Bangkok, Hanoi, Jakarta 
      => 55, # +07:00 - Krasnoyarsk 
      => 56, # +08:00 - Beijing, Chongqing, Hong Kong, Urumqi 
      => 57, # +08:00 - Irkutsk, Ulaan Bataar  
      => 75, # +01:00 - Namibia 
      => 76, # +02:00 - Jordan, Palestine 
    }

=end

    tone_schemes_map = {
      nil => 0, # International
      1 => 1,   # United States
      41 => 2,  # Switzerland
      27 => 3,  # South Africa
      43 => 4,  # Austria
      420 => 5, # Czech Republic
      34 => 6,  # Spain
      33 => 7,  # France
      44 => 8,  # Great Britain
      31 => 9,  # Netherlands
      48 => 10, # Poland
      49 => 12, # Germany
      7 => 11,  # Russia
      39 => 13, # Italy
    }

    codec_map = {
      'ulaw' => 0,
      'alaw' => 1,
      'g726' => 2,
      'g729' => 3,
      'g722' => 5,
      nil => 255,
    }


    codecs_available = [1, 0, 5, 2, 3]
    codecs_preferred = [1, 0, 255, 255, 255]

    @settings = {
      'BS_IP_Data.ucB_AUTO_UPDATE_PROFILE' => "1",
      'BS_IP_Data3.ucI_ONESHOT_PROVISIONING_MODE_1' => "1",
      'BS_IP_Data1.ucI_DIALING_PLAN_COUNTRY_ID' => "78",
      'BS_IP_Data1.aucS_DATA_SERVER[0]' => "\"#{request.host_with_port}/gigaset\"",
      'BS_IP_Data1.uiI_TIME_COUNTRY' => "25",
      'BS_IP_Data1.uiI_TIME_TIMEZONE' => "27",
      'BS_IP_Data1.ucB_CT_AFTER_ON_HOOK' => "1",
      'BS_CUSTOM_ORG.bit.bEct' => "1",
      'BS_AE_SwConfig.ucCountryCodeTone' => "9",
      'BS_IP_Data1.ucB_ACCEPT_FOREIGN_SUBNET' => "1",
      'BS_IP_Data1.ucB_ACCEPT_FOREIGN_SUBNET..attr' => "1",
      'BS_XML_Netdirs.astNetdirProvider[1].aucServerURL' => '""',
      'BS_XML_Netdirs.astNetdirProvider[1].aucWhitePagesDirName' => '"GS5"',
      'BS_XML_Netdirs.astNetdirProvider[1].aucUsername' => '""',
      'BS_XML_Netdirs.astNetdirProvider[1].aucPassword' => '""',
    }

    if ! @phone.http_password.blank?
      pin = @phone.http_password.to_s + '0000'
      @settings['BS_CUSTOM.aucKdsPin[0]'] = "0x#{pin.byteslice(0,2)},0x#{pin.byteslice(2,2)}"
    end

    for index in 1..MAX_SIP_ACCOUNTS
      @settings["BS_IP_Data1.aucS_SIP_ACCOUNT_NAME_#{index}"] = "\"SIP#{index}\""
      @settings["BS_IP_Data1.ucB_SIP_ACCOUNT_IS_ACTIVE_#{index}"] = "0"
      @settings["BS_IP_Data1.aucS_VOIP_NET_AM_NUMBER_#{index}"] = '"*98#"' 
      @settings["BS_IP_Data1.ucB_VOIP_NET_AM_ENABLED_#{index}"] = "1" 
      @settings["BS_IP_Data1.ucB_SIP_ACCOUNT_IS_ACTIVE_#{index}..attr"] = "UI_LOCK"
      @settings["BS_IP_Data1.ucI_LOUDNESS_#{index}"] = "0" 
      @settings["BS_Accounts.astAccounts[#{index-1}].aucAccountName[0]"] = "\"SIP#{index}\""

      if index == 1
        @settings["BS_IP_Data1.aucS_SIP_DISPLAYNAME"] = '""'
        @settings["BS_IP_Data3.aucS_SIP_LOGIN_ID"] = '""'
        @settings["BS_IP_Data1.aucS_SIP_PASSWORD"] = '""'
        @settings["BS_IP_Data1.aucS_SIP_USER_ID"] = '""'
        @settings["BS_IP_Data1.aucS_SIP_DOMAIN"] = '""' 
        @settings["BS_IP_Data1.aucS_SIP_SERVER"] = '""' 
        @settings["BS_IP_Data1.aucS_SIP_REGISTRAR"] = '""' 
        @settings["BS_IP_Data1.aucS_STUN_SERVER"] = '""' 
        @settings["BS_IP_Data1.aucS_OUTBOUND_PROXY"] = '""' 
        @settings["BS_IP_Data1.aucS_SIP_PROVIDER_NAME"] = '"GS5"' 
        @settings["BS_IP_Data1.uiI_SIP_SERVER_PORT"] = "5060" 
        @settings["BS_IP_Data1.uiI_SIP_REGISTRAR_PORT"] = "5060" 
        @settings["BS_IP_Data1.ucB_SIP_USE_STUN"] = "0" 
        @settings["BS_IP_Data1.uiI_STUN_SERVER_PORT"] = "3478" 
        @settings["BS_IP_Data1.ucI_OUTBOUND_PROXY_MODE"] = "1" 
        @settings["BS_IP_Data1.uiI_OUTBOUND_PROXY_PORT"] = "5060" 
        @settings["BS_IP_Data1.uiI_RE_REGISTRATION_TIMER"] = "60" 
        @settings["BS_IP_Data1.uiI_RE_STUN_TIMER"] = "60" 
        @settings["BS_IP_Data1.ucI_SIP_PREFERRED_VOCODER"] = codecs_preferred.join(',')
        @settings["BS_IP_Data1.ucI_SIP_AVAILABLE_VOCODER"] = codecs_available.join(',')
        @settings["BS_IP_Data1.ucB_VOIP_CALLFORWARDING_STATUS"] = "0"
      else
        @settings["BS_IP_Data1.aucS_SIP_DISPLAYNAME_#{index}"] = '""'
        @settings["BS_IP_Data3.aucS_SIP_LOGIN_ID_#{index}"] = '""'
        @settings["BS_IP_Data1.aucS_SIP_PASSWORD_#{index}"] = '""'
        @settings["BS_IP_Data1.aucS_SIP_USER_ID_#{index}"] = '""'
        @settings["BS_IP_Data1.aucS_SIP_DOMAIN_#{index}"] = '""' 
        @settings["BS_IP_Data1.aucS_SIP_SERVER_#{index}"] = '""' 
        @settings["BS_IP_Data1.aucS_SIP_REGISTRAR_#{index}"] = '""' 
        @settings["BS_IP_Data1.aucS_STUN_SERVER_#{index}"] = '""' 
        @settings["BS_IP_Data1.aucS_OUTBOUND_PROXY_#{index}"] = '""' 
        @settings["BS_IP_Data1.aucS_SIP_PROVIDER_NAME_#{index}"] = '"GS5"' 
        @settings["BS_IP_Data1.uiI_SIP_SERVER_PORT_#{index}"] = "5060" 
        @settings["BS_IP_Data1.uiI_SIP_REGISTRAR_PORT_#{index}"] = "5060" 
        @settings["BS_IP_Data1.ucB_SIP_USE_STUN_#{index}"] = "0" 
        @settings["BS_IP_Data1.uiI_STUN_SERVER_PORT_#{index}"] = "3478" 
        @settings["BS_IP_Data1.ucI_OUTBOUND_PROXY_MODE_#{index}"] = "1" 
        @settings["BS_IP_Data1.uiI_OUTBOUND_PROXY_PORT_#{index}"] = "5060" 
        @settings["BS_IP_Data1.uiI_RE_REGISTRATION_TIMER_#{index}"] = "60" 
        @settings["BS_IP_Data1.uiI_RE_STUN_TIMER_#{index}"] = "60" 
        @settings["BS_IP_Data1.ucI_SIP_PREFERRED_VOCODER_#{index}"] = codecs_preferred.join(',')
        @settings["BS_IP_Data1.ucI_SIP_AVAILABLE_VOCODER_#{index}"] = codecs_available.join(',')
        @settings["BS_IP_Data1.ucB_VOIP_CALLFORWARDING_STATUS_#{index}"] = "0"
      end
      
      mask = 0
      if index > MAX_HANDSETS
        @settings["BS_Accounts.astAccounts[#{index-1}].ucState"] = 0
      else
        @settings["BS_Accounts.astAccounts[#{index-1}].ucState"] = 1
        mask = 2**(index-1)
      end
      @settings["BS_Accounts.astAccounts[#{index-1}].uiSendMask"] = mask
      @settings["BS_Accounts.astAccounts[#{index-1}].uiReceiveMask"] = mask
    end

    for index in 1..MAX_HANDSETS
      @settings["BS_AE_Subscriber.stMtDat[#{index-1}].aucTlnName"] = "\"HS#{index}\""
    end

    sip_accounts = @phone.sip_accounts.any? ? @phone.sip_accounts : [@phone.fallback_sip_account]

    sip_accounts.each_with_index do |sip_account, index|
      config_changed << sip_account.updated_at
      @settings["BS_IP_Data1.aucS_SIP_ACCOUNT_NAME_#{index+1}"] = "\"#{sip_account.caller_name}\""
      @settings["BS_IP_Data1.ucB_SIP_ACCOUNT_IS_ACTIVE_#{index+1}"] = "1"
      @settings["BS_Accounts.astAccounts[#{index}].aucAccountName[0]"] = sip_account.phone_numbers.first ? "\"#{sip_account.phone_numbers.first.number}\"" : "\"#{sip_account.caller_name}\""

      if index == 0
        @settings["BS_IP_Data1.aucS_SIP_DISPLAYNAME"] = "\"#{sip_account.caller_name}\""
        @settings["BS_IP_Data3.aucS_SIP_LOGIN_ID"] = "\"#{sip_account.auth_name}\""
        @settings["BS_IP_Data1.aucS_SIP_PASSWORD"] = "\"#{sip_account.password}\""
        @settings["BS_IP_Data1.aucS_SIP_USER_ID"] = "\"#{sip_account.auth_name}\""
        @settings["BS_IP_Data1.aucS_SIP_DOMAIN"] = "\"#{sip_account.sip_domain}\""
        @settings["BS_IP_Data1.aucS_SIP_SERVER"] = "\"#{sip_account.sip_domain}\""
      else
        @settings["BS_IP_Data1.aucS_SIP_DISPLAYNAME_#{index+1}"] = "\"#{sip_account.caller_name}\""
        @settings["BS_IP_Data3.aucS_SIP_LOGIN_ID_#{index+1}"] = "\"#{sip_account.auth_name}\""
        @settings["BS_IP_Data1.aucS_SIP_PASSWORD_#{index+1}"] = "\"#{sip_account.password}\""
        @settings["BS_IP_Data1.aucS_SIP_USER_ID_#{index+1}"] = "\"#{sip_account.auth_name}\""
        @settings["BS_IP_Data1.aucS_SIP_DOMAIN_#{index+1}"] = "\"#{sip_account.sip_domain}\""
        @settings["BS_IP_Data1.aucS_SIP_SERVER_#{index+1}"] = "\"#{sip_account.sip_domain}\""
      end

      if index <= MAX_HANDSETS-1 && sip_account.phone_numbers.first
        @settings["BS_AE_Subscriber.stMtDat[#{index}].aucTlnName"] = "\"#{sip_account.phone_numbers.first.number}\""
      end
    end

    mask = 0
    for index in 1..MAX_HANDSETS
      if sip_accounts.count <= index
        if sip_accounts.last.phone_numbers.first
          @settings["BS_AE_Subscriber.stMtDat[#{index-1}].aucTlnName"] = "\"#{index}:#{sip_accounts.last.phone_numbers.first.number}\""
        end
        mask = mask + 2**(index-1)
        @settings["BS_Accounts.astAccounts[#{sip_accounts.count-1}].uiSendMask"] = mask
        @settings["BS_Accounts.astAccounts[#{sip_accounts.count-1}].uiReceiveMask"] = mask
      end
    end

    if sip_accounts.any?
      phone_book_url = "#{request.protocol}#{request.host_with_port}/config_gigaset/#{@phone.id}/#{sip_accounts.first.id}/phone_book.xml"
      @settings['BS_XML_Netdirs.astNetdirProvider[1].aucServerURL'] = "\"#{phone_book_url}\""
    end

    @config_version = config_changed.sort.last.utc.strftime('%d%m%y%H%M')
  end


  def binary
    file_name = params[:file_name].to_s
    block = case file_name
    when /^master/
      block_encode(3, 'sifsroot.bin')
    when /^sifsroot/
      block_encode(4, 'sih.bin')
    when /^sih/
      block_encode(4, 'sit.bin')
    when /^sit/
      block_encode(4, 'siu.bin')
    when /^siu/
      block_encode(0, "#{request.protocol}#{request.host_with_port}/gigaset/%DVID/settings-%MACD.xml")
    end

    send_data block, :type => 'application/octet-stream',:disposition => 'inline'
  end

  def phone_book
    @phone = Phone.where({ :id => params[:phone].to_i }).first
    if ! @phone
      render(
        :status => 404,
        :layout => false,
        :content_type => 'text/plain',
        :text => "<!-- Phone not found -->",
      )
      return false
    end

    if @phone.sip_accounts.any?
      sip_accounts = @phone.sip_accounts
    else
      sip_accounts = [@phone.fallback_sip_account]
    end

    if ! sip_accounts.any?
      render(
        :status => 404,
        :layout => false,
        :content_type => 'text/plain',
        :text => "<!-- SIP account not found -->",
      )
      return false
    end

    base_url = "#{request.protocol}#{request.host_with_port}/config_gigaset/#{@phone.id}/#{sip_accounts.first.id}"
    phone_book_url = "#{base_url}/phone_book.xml"
  end

  private
  def block_encode(block_type, value)
    return [
      block_type,
      value.length+3,
      0x03,
      value.length+1,
      value,
    ].pack("CCCCa#{value.length+1}")

  end
end