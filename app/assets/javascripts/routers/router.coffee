class ProprietasApp.Router extends Backbone.Router
        
    routes:
        "": "index"
        
    index: ->
        state = new ProprietasApp.State()
        view = new ProprietasApp.StateView(model:state)
        $('body').append(view.render().el)