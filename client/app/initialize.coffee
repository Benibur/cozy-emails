# Waits for the DOM to be ready
window.onload = ->

    window.__DEV__ = window.location.hostname is 'localhost'
    # use Cozy instance locale or navigator language or "en" by default
    locale = window.locale or window.navigator.language or "en"
    moment.locale locale
    locales = {}
    try
        locales = require "./locales/#{locale}"
    catch err
        console.log err
        locales = require "./locales/en"
    polyglot = new Polyglot()
    # we give polyglot the data
    polyglot.extend locales
    # handy shortcut
    window.t = polyglot.t.bind polyglot

    # init plugins
    if not window.plugins?
        window.plugins = {}
    if MutationObserver?
        # Observes DOM mutation to see if a plugin should be called
        observer = new MutationObserver (mutations) ->
            checkNode = (node) ->
                if node.nodeType isnt Node.ELEMENT_NODE
                    return

                for own pluginName, pluginConf of window.plugins
                    if pluginConf.active
                        if pluginConf.onAdd?
                            if pluginConf.onAdd.condition node
                                pluginConf.onAdd.action node

            check = (mutation) ->
                nodes = Array.prototype.slice.call mutation.addedNodes
                checkNode node for node in nodes

            check mutation for mutation in mutations

        config =
            attributes: false
            childList: true
            characterData: false
            subtree: true
        observer.observe document.body, config

    else
        # Dirty fallback for IE
        # @TODO use polyfill ???
        setInterval ->
            for own pluginName, pluginConf of window.plugins
                if pluginConf.active
                    if pluginConf.onAdd?
                        if pluginConf.onAdd.condition document.body
                            pluginConf.onAdd.action document.body

        , 200


    # Flux initialization (must be called at the begining)
    AccountStore  = require './stores/AccountStore'
    LayoutStore   = require './stores/LayoutStore'
    MessageStore  = require './stores/MessageStore'
    SettingsStore = require './stores/SettingsStore'
    SearchStore   = require './stores/SearchStore'


    # Routing management
    Router = require './router'
    @router = new Router()
    window.router = @router

    # Binds the router and flux to the React application
    Application = require './components/application'
    application = Application router: @router
    React.renderComponent application, document.body


    # Starts the application by initializing the router
    Backbone.history.start()


    # Makes this object immuable.
    Object.freeze this if typeof Object.freeze is 'function'
