class window.ProprietasApp.StateView extends Backbone.View
    
    id: "state"
    
    render: ->
        template = JST['state_view']( @model.toJSON() )
        $(@el).html(template);
        this