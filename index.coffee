yargs = require('yargs').argv
config = require('./conf/config')
sensors = require 'sensors'

if yargs["serial-host"]?
  config.serial.host = yargs["serial-host"]
else
  throw Error("Need to specify serial host.")

if yargs["serial-port"]?
  config.serial.port = yargs["serial-port"]

if yargs["mqtt-host"]?
  config.mqtt.host = yargs["mqtt-host"]
else
  throw Error("Need to specify mqtt host.")

if yargs["mqtt-port"]?
  config.mqtt.port = yargs["mqtt-port"]

client = require('./mqtt').get()
Serial = require './serial'
serial = new Serial( host: config.serial.host, port: config.serial.port, client)
