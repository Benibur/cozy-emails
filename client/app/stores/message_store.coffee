Store = require '../libs/flux/store/store'
AppDispatcher = require '../app_dispatcher'

AccountStore = require './account_store'

{ActionTypes, MessageFlags, MessageFilter} = require '../constants/app_constants'

class MessageStore extends Store

    ###
        Initialization.
        Defines private variables here.
    ###

    _sortField   = 'date'
    _sortOrder   = 1
    _filter      = MessageFilter.ALL
    _quickFilter = ''
    __getSortFunction = (criteria) ->
        sortFunction = (message1, message2) ->
            if typeof message1.get is 'function'
                val1 = message1.get criteria
                val2 = message2.get criteria
            else
                val1 = message1[criteria]
                val2 = message2[criteria]
            if val1 > val2 then return -1 * _sortOrder
            else if val1 < val2 then return 1 * _sortOrder
            else return 0

    __sortFunction = __getSortFunction 'date'

    # Creates an OrderedMap of messages
    _messages = Immutable.Sequence()

        # sort first
        .sort __sortFunction

        # sets message ID as index
        .mapKeys (_, message) -> message.id

        # makes message object an immutable Map
        .map (message) -> Immutable.fromJS message
        .toOrderedMap()

    _counts       = Immutable.Map()
    _unreadCounts = Immutable.Map()


    _view = Immutable.Sequence()
    _currentMailbox = null

    # Create a view of messages in current mailbox according to filters and
    # sort criteria
    _getView: ->
        _view = _messages.filter (message) ->
            return _currentMailbox in Object.keys message.get 'mailboxIDs'
        .sort(__getSortFunction _sortField)

        if _filter isnt MessageFilter.ALL
            if _filter is MessageFilter.FLAGGED
                filterFunction = (message) ->
                    return MessageFlags.FLAGGED in message.get 'flags'
            else if _filter is MessageFilter.UNSEEN
                filterFunction = (message) ->
                    return MessageFlags.SEEN not in message.get 'flags'
        if filterFunction?
            _view = _view.filter filterFunction

        if _quickFilter isnt ''
            re = new RegExp _quickFilter, 'i'
            _view = _view.filter (message) ->
                return re.test(message.get 'subject')

    ###
        Defines here the action handlers.
    ###
    __bindHandlers: (handle) ->

        handle ActionTypes.RECEIVE_RAW_MESSAGE, onReceiveRawMessage = \
        (message, silent = false) ->
            # create or update
            message.hasAttachments = Array.isArray(message.attachments) and \
                                     message.attachments.length > 0
            if not message.createdAt?
                message.createdAt = message.date
            if not message.attachments?
                message.attachments = []
            # Add messageId to every attachment
            message.attachments = message.attachments.map (file) ->
                file.messageId = message.id
                return file

            if not message.flags?
                message.flags = []
            # message loaded from fixtures for test purpose have a docType
            # that may cause some troubles
            delete message.docType
            message = Immutable.Map message
            _messages = _messages.set message.get('id'), message

            @emit 'change' unless silent

        handle ActionTypes.RECEIVE_RAW_MESSAGES, (messages) ->

            if messages.count? and messages.mailboxID?
                _counts = _counts.set messages.mailboxID, messages.count
                _unreadCounts = _unreadCounts.set messages.mailboxID, messages.unread
                messages = messages.messages.sort __sortFunction

            onReceiveRawMessage message, true for message in messages
            @_getView()
            @emit 'change'

        handle ActionTypes.REMOVE_ACCOUNT, (accountID) ->
            AppDispatcher.waitFor [AccountStore.dispatchToken]
            messages = @getMessagesByAccount accountID
            _messages = _messages.withMutations (map) ->
                messages.forEach (message) -> map.remove message.get 'id'

            @emit 'change'

        handle ActionTypes.MESSAGE_SEND, (message) ->
            # message should have been copied to Sent mailbox,
            # so it seems reasonable to emit change
            onReceiveRawMessage message, true
            @emit 'change'

        handle ActionTypes.MESSAGE_DELETE, (message) ->
            # message should have been deleted from current mailbox
            # and copied to trash
            # so it seems reasonable to emit change
            @emit 'change'

        handle ActionTypes.MESSAGE_BOXES, (message) ->
            @emit 'change'

        handle ActionTypes.MESSAGE_FLAG, (message) ->
            @emit 'change'

        handle ActionTypes.LIST_FILTER, (filter) ->
            _filter = filter
            @_getView()
            @emit 'change'

        handle ActionTypes.LIST_QUICK_FILTER, (filter) ->
            _quickFilter = filter
            @_getView()
            @emit 'change'

        handle ActionTypes.LIST_SORT, (sort) ->
            _sortField = sort.field
            _sortOrder = sort.order
            @_getView()
            @emit 'change'


    ###
        Public API
    ###
    getAll: -> return _messages

    getByID: (messageID) -> _messages.get(messageID) or null

    ###*
    * Get messages from account, with optional pagination
    *
    * @param {String} accountID
    * @param {Number} first     index of first message
    * @param {Number} last      index of last message
    *
    * @return {Array}
    ###
    getMessagesByAccount: (accountID, first = null, last = null) ->
        sequence = _messages.filter (message) ->
            return message.get('account') is accountID
        if first? and last?
            sequence = sequence.slice first, last

        # sequences are lazy so we need .toOrderedMap() to actually execute it
        return sequence.toOrderedMap()


    getMessagesCountByAccount: (accountID) ->
        return @getMessagesByAccount(accountID).count()

    ###*
    * Get messages from mailbox, with optional pagination
    *
    * @param {String} mailboxID
    * @param {Number} first     index of first message
    * @param {Number} last      index of last message
    *
    * @return {Array}
    ###
    getMessagesByMailbox: (mailboxID, first = null, last = null) ->

        if mailboxID isnt _currentMailbox
            _currentMailbox = mailboxID
            @_getView()

        if first? and last?
            sequence = _view.slice first, last
            return sequence.toOrderedMap()
        else
            return _view

    getPreviousMessageID: (messageID) ->
        keys = _view.keySeq()
        index = keys.indexOf messageID
        if index?
            return keys.get --index

    getNextMessageID: (messageID) ->
        keys = _view.keySeq()
        index = keys.indexOf messageID
        if index?
            return keys.get ++index

    getMessagesCounts: ->
        return _counts

    getUnreadMessagesCounts:  ->
        return _unreadCounts

    getMessagesByConversation: (messageID) ->
        idsToLook = [messageID]
        conversation = []
        while idToLook = idsToLook.pop()
            conversation.push @getByID idToLook
            temp = _messages.filter (message) ->
                return message.get('inReplyTo') is idToLook
            newIdsToLook = temp.map((item) -> item.get('id')).toArray()
            idsToLook = idsToLook.concat newIdsToLook

        return conversation

module.exports = new MessageStore()
