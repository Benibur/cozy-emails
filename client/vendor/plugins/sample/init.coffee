if not window.plugins
    window.plugins = {}

window.plugins.sample =
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
