class window.ProprietasApp
    sanity: -> true
    
    constructor: ->
        new ProprietasApp.Router()
        Backbone.history.start()