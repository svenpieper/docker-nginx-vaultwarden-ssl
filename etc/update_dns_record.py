#!/usr/bin/env python
# encoding: utf-8

import threading
from datetime import datetime
import logging
from logging.handlers import RotatingFileHandler
import requests


HOSTNAME = "YOUR_HOSTNAME"  # hostname (including subdomain)
APIKEY = "YOUR_DDNS_APIKEY"  # DDNS Token
CURR_IP = '00.00.00.000'  # Your current IP set in your domain DynDNS settings
INTERVAL_S = 20160  # quarter day
LOG_FILE = "logs/dyndns.log"  # dasdf


# Creating a RotationFileHandler to make sure the log wont get bigger than 5 MB
# Keep the last 2 rotated logs.
my_handler = RotatingFileHandler(LOG_FILE, mode='a', maxBytes=1024*1024*5,
                                 backupCount=2, encoding=None, delay=0)
my_handler.setLevel(logging.INFO)
app_log = logging.getLogger('root')
app_log.setLevel(logging.INFO)
app_log.addHandler(my_handler)


def get_ip() -> str:
    """Get your current IPv4 address

    :return: your current IPv4 address
    :rtype: str
    """
    response = requests.get("https://ifconfig.co/json").json()
    return response['ip']


def update_record(ipv4: str) -> int:
    """Updates the A record via a get requests.
    The url must be changed to your needs

    :param ip: Your current IPv4 address
    :type ip: str
    :return: HTTP status code
    :rtype: int
    """
    try:
        # ------------------------------------------
        # - - - - - MAKE CHANGES HERE - - - - - - -
        # ------------------------------------------
        # Have a look at the API instructions of
        # your domain provider and change the "url"
        # variable to your needs ...
        # ------------------------------------------
        url = f"https://theapiurl.com?host={HOSTNAME}?password={APIKEY}?ipv4={ipv4}"
        return requests.get(url=url, timeout=25).status_code
    except:
        return 404


def wake_up():
    """This method will run indefinitely. It will check the DNS record every
    INTERVAL_S seconds. In case the IPv4 address didnt change it wont send a
    get request to the domain provider.
    """
    global CURR_IP
    ipv4 = get_ip()
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    app_log.info(f"Current timestamp: {current_time}")
    app_log.info(f"External IP: {ipv4}")
    if ipv4 != CURR_IP:
        app_log.warning("IPv4 A record needs to be updated.")
        response = update_record(ipv4)
        if response == 404:
            app_log.error("Update failed.\n")
        else:
            app_log.info("Update successfull.\n")
            CURR_IP = ipv4
    else:
        app_log.info("IPv4 A record still valid.\n")
    sleep_thread = threading.Timer(INTERVAL_S, wake_up)
    sleep_thread.start()


sleep_thread = threading.Timer(0, wake_up)
sleep_thread.start()
