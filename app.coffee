st = require 'syncthing-node'

st.version()
    .then (result) ->
        console.log 'Version: ' + result
    .catch (error) ->
        console.log 'Error while attempting to get version: ' + error
