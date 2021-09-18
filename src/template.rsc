# RouterOS sending message to Telegram on DHCP envents
# ====================================================
# 
# DHCP triggering script with agurments (lease-script)
#   See: https://wiki.mikrotik.com/wiki/Manual:IP/DHCP_Server#General
# 
# Send request POST
#   See: https://help.mikrotik.com/docs/display/ROS/Fetch
# 

:local botToken;
:local chatId;
:local telegramUrl;
:local ip;
:local mac;
:local banner;
:local message;
:local jsonBody;

# >>> python
inject(':set botToken ', os.environ.get('TELEGRAM_BOT_TOKEN'), ';')
inject(':set chatId ', os.environ.get('TELEGRAM_CHAT_ID'), ';')
# <<<

:set telegramUrl "https://api.telegram.org/$botToken/sendMessage"
:set banner $"lease-hostname";
:set ip $leaseActIP;
:set mac $leaseActMAC;

# >>> python
inject(':set message "', load_message_html(), '";')
# <<<

:set jsonBody "{\"chat_id\": $chatId, \"text\": \"$message\", \"parse_mode\": \"HTML\"}";

:if ($leaseBound = 1) do={
    # Only triggered on association events.
    # To catch disassociation events, use "$leaseBound = 0".
    /tool fetch http-method=post http-header-field="content-type:application/json" http-data=$jsonBody url=$telegramUrl output=none;
}
