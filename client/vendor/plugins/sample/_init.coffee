if not window.plugins
    window.plugins = {}

window.plugins.sample =
    name: "Sample Coffee"
    active: true
    onAdd:
        ###
        * Should return true if plugin applies on added subtree
        *
        * @param {DOMNode} root node of added subtree
        ###
        condition: (node) ->
            return false
        ###
        * Perform action on added subtree
        *
        * @param {DOMNode} root node of added subtree
        ###
        action: (node) ->
            node.setAttribute 'data-plugin', true
    ###
    * Called when plugin is activated
    ###
    onActivate: ->
        console.log 'Plugin sample activated'
    ###
    * Called when plugin is deactivated
    ###
    onDeactivate: ->
        console.log 'Plugin sample deactivated'
