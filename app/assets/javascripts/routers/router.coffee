class ProprietasApp.Router extends Backbone.Router
        
    routes:
        "": "index"
        
    index: ->
        party = new ProprietasApp.Party()
        view = new ProprietasApp.PartyView(model:party)
        $('body').append(view.render().el)