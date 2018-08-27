import {ContainerComponent} from 'abstract/ContainerComponent'
import {Searcher}           from 'view/Searcher'
import {TextContainer}      from 'view/Text'

import * as basegl from 'basegl'
import * as style  from 'style'
import * as shape  from 'shape/node/Base'


export class EditableText extends ContainerComponent

    @NAME:       'editable-name'
    @EXPRESSION: 'editable-expr'

    ################################
    ### Initialize the component ###
    ################################

    initModel: =>
        key: null
        input: null
        text: ''
        inputSelection: null
        selected: 0
        entries: []
        position: [0, 0]
        edited: false
        kind: EditableText.NAME

    #############################
    ### Create/update the DOM ###
    #############################

    update: =>
        anyChanged = Object.values(@changed).some((v) -> v)
        return unless anyChanged

        @autoUpdateDef 'searcher', Searcher, if @model.edited
            key:            @model.key
            input:          @model.input || ""
            inputSelection: @model.inputSelection
            selected:       @model.selected
            entries:        @model.entries
        @autoUpdateDef 'text', TextContainer, unless @model.edited
            text:  @model.text
            align: 'center'

    hideSearcher: =>
        @set edited: false
        @root.unregisterSearcher()

    showSearcher: (notify = true) =>
        @set edited: true
        @root.registerSearcher @
        tag = if (@model.kind == EditableText.NAME)
                'EditNodeNameEvent'
            else
                'EditNodeExpressionEvent'
        if notify
            @pushEvent tag: tag

    setSearcher: (searcherModel) =>
        @set
            key:            searcherModel.key
            input:          searcherModel.input
            inputSelection: searcherModel.inputSelection
            selected:       searcherModel.selected
            entries:        searcherModel.entries
            edited:         true
        @showSearcher false

    ###################################
    ### Register the event handlers ###
    ###################################

    registerEvents: (view) =>
        __makeEdited = (e) =>
            @addDisposableListener window, 'keyup', __makeUnedited
            @showSearcher()

        __makeUnedited = (e) =>
            if e.code == 'Escape'
                window.removeEventListener 'keyup', __makeUnedited
                @hideSearcher()

        @addDisposableListener view, 'dblclick', __makeEdited
