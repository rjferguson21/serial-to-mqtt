eversocket = require('eversocket').EverSocket
sensors = require 'sensors'
winston = require 'winston'
Promise = require 'bluebird'

winston.remove winston.transports.Console
winston.add(winston.transports.Console, {'timestamp':true})

NAMESPACE = 'MyMQTT'

Serial = (conf, mqtt_conn) ->
  self = this
  self.client = mqtt_conn
  self.socket = new eversocket
    reconnectWait: 100
    reconnectOnTimeout: false

  self.socket.connect conf.port, conf.host

  self.socket.on 'connect', ->
    console.log 'Serial connection established.'

  self.socket.on 'reconnect', ->
    console.log 'Serial connection reconnected.'

  self.socket.on 'data', (data) ->
    str = new Buffer(data).toString('ascii')
    winston.log 'info', str
    args = Serial.to_mqtt data

    # Publish mqtt serialized message
    self.client.publish args[0], args[1]

  self.socket.on 'error', (data) ->
    console.log 'Serial connection error!', arguments, data

  self.socket.on 'end', ->
    console.log 'end'

  return self

Serial::ping = ->
  self = this
  new Promise (resolve, reject) ->
    self.socket.write '0;0;3;0;2; \n'
    self.socket.once 'data', resolve

Serial::send = (message) ->
  this.socket.write message

Serial.to_mqtt = (data) ->
  serial_msg = new Buffer(data).toString('ascii')
  m = serial_msg.split(';')
  m.unshift NAMESPACE
  payload = m.pop().trim()
  return [ m.join('/'), payload ]

Serial.to_serial = (topic, message) ->
  m = topic.split '/'
  prefix = m.shift()
  throw new Error('Prefix does not match') if prefix isnt NAMESPACE
  m.push message
  m = m.join ';'
  m += "\n"
  return m

module.exports = Serial
