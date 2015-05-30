{ map, filter, fold1, find, keys, values, first, last, flatten } = require 'prelude-ls'

st = require 'syncthing-node'
p = require 'bluebird-extra'
h = require 'helpers'
colors = require 'colors'

require! [ util ]


self = 'osvetnik'

p.all([st.getConfig(), st.getConnections()])
    .then (result) ->
      [ config, connections ] = result
      
      devices = h.dictFromArray config.Devices, ->
        if it.Name is self then return
        deviceID = it.DeviceID

        deviceFolders = h.dictFromArray config.Folders, ->
          if (deviceID in map (-> it.DeviceID), (it.Devices or []))
            [ it.ID, h.extend({}, it) ]
          
        [ it.Name, h.extend it, (connections[deviceID] or {}), { Folders: deviceFolders or [] } ]

      p.mapOwn( devices, (deviceData,deviceName) -> new p (resolve,reject) ->

        p.mapOwn(deviceData.Folders, (folder,folderName) -> new p (resolve,reject) ->
          st.getCompletion(deviceData.DeviceID,folderName).then (result) ->
            folder.completion = result.completion
            resolve folder).then -> resolve h.extend deviceData, Folders: it
              
            ).then (result) ->
              h.map result, (deviceData, deviceName) ->
                console.log ''
                if deviceData.Address
                  console.log colors.green(h.rpad(deviceName,7,' ')), colors.blue(deviceData.Address)
                else
                  console.log colors.red(deviceName)
                h.map deviceData.Folders, (folderData, folderName) -> console.log colors.yellow(h.pad(folderName, 14, ' ')), ' ', colors.green(folderData.completion+ " %")
                
              console.log ''
        



#        console.log config
    .catch (error) ->
        console.log 'Error', error.stack


