import {ContainerComponent} from 'abstract/ContainerComponent'
import {Searcher}           from 'view/Searcher'
import {TextShape}          from 'shape/Text'

import * as basegl from 'basegl'
import * as style  from 'style'
import * as shape  from 'shape/node/Base'


export class EditableText extends ContainerComponent

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

    prepare: =>
        console.log "EditableText::prepare"
        # console.log "@model: ", @model

        @addDef 'text', new TextShape
                text: @model.text
            , @
        @addDef 'searcher', new Searcher
                key:            @model.key
                input:          @model.input
                text:           @model.text
                inputSelection: @model.inputSelection
                selected:       @model.selected
                entries:        @model.entries
                position:       @model.position
            , @

    #############################
    ### Create/update the DOM ###
    #############################

    update: =>
        console.log "EditableText::update"
        console.log "@model: ", @model
        @updateDef 'searcher', entries: @model.entries

    #######################
    ### Adjust the view ###
    #######################

    adjust: (view) =>
        console.log "EditableText::adjust"
    
    __onPositionChanged: (parentNode) =>
        console.log "Changing position along with the parent"
        @set position: parentNode.model.position

    ###################################
    ### Register the event handlers ###
    ###################################

    registerEvents: (view) =>
        console.log "EditableText::registerEvents"
        @view('text').addEventListener 'dblclick', (e) => console.log "Doubleclick on #{@model.text}"
        view.addEventListener 'mouseenter', => console.log "Siup"
        
        parentNode = @model.parent
        if parentNode?
            @__onPositionChanged parentNode
            @addDisposableListener parentNode, 'position', =>
                @__onPositionChanged parentNode