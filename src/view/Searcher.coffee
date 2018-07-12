import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape} from 'shape/Html'

import * as basegl from 'basegl'
import * as style  from 'style'
import * as shape  from 'shape/node/Base'


searcherRoot    = 'searcher-root'
searcherWidth   = 400  # same as `@searcherWidth` in `_searcher.less`
searcherBaseOffsetX = -searcherWidth / 8
searcherBaseOffsetY = shape.height   / 8


export class Searcher extends ContainerComponent

    ################################
    ### Initialize the component ###
    ################################

    initModel: =>
        console.log "Searcher: init model"
        key: null
        input: null
        inputSelection: null
        selected: 0
        entries: []
        position: [0, 0]
        parent: null

    prepare: =>
        console.log "===== Searcher: prepare ======"
        @dom = {}
        @addDef 'root', new HtmlShape
                element: 'div'
                id: 'searcher-root'
                scalable: false
            , @

    #############################
    ### Create/update the DOM ###
    #############################

    update: =>
        console.log "Searcher: update"
        @__createDom() unless @dom.container?
        @__updateResults() if @changed.entries
        @__updateInput() if @changed.input
        @dom.input.focus()

    __createDom: =>
        @__createResults()
        @__createInput()
        @__createContainer()

    __createContainer: =>
        @dom.container = document.createElement 'div'
        @dom.container.className = 'native-key-bindings ' + style.luna ['input', 'searcher', 'searcher--node']
        @dom.container.appendChild @dom.results
        @dom.container.appendChild @dom.input
        @def('root').getDomElement().appendChild @dom.container

    __createResults: =>
        @dom.results = document.createElement 'div'
        @dom.results.className = style.luna ['searcher__results']
        @dom.resultsList = document.createElement 'div'
        @dom.resultsList.className = style.luna ['searcher__results__list']
        @dom.results.appendChild @dom.resultsList

    __createInput: =>
        @dom.input = document.createElement 'input'
        @dom.input.type = 'text'
        @dom.input.className = style.luna ['searcher__input']

    __updateResults: =>
        @dom.resultsList.innerText = ''
        omit = Math.max(0, @model.selected - 1)
        i = omit + 1
        @model.entries.slice(omit).forEach (entry) =>
            @dom.resultsList.appendChild @__renderResult entry, i == @model.selected
            i++

    __updateInput: =>
        inputClasses = ['searcher__input']
        inputClasses.push ['searcher__input-selected'] if @model.selected == 0
        inputClasses.push ['searcher__no-results'] if @model.entries.length == 0
        @dom.input.className = style.luna inputClasses
        if @model.inputSelection?.length == 2
            @dom.input.selectionStart = @model.inputSelection[0]
            @dom.input.selectionEnd   = @model.inputSelection[1]
            @model.inputSelection = null
        return @dom.input

    __renderResult: (entry, selected) =>
        resultName = document.createElement 'div'
        resultName.className = style.luna ['searcher__results__item__name']
        resultName.appendChild @__renderPrefix entry.className or ''
        resultName.appendChild @__renderHighlights entry.name, entry.highlights

        result = document.createElement 'div'
        resultClasses = ['searcher__results__item']
        resultClasses.push ['searcher__results__item--selected'] if selected
        result.className = style.luna resultClasses
        result.appendChild resultName
        return result

    __renderPrefix: (prefix) ->
        prefixSpan = document.createElement 'span'
        prefixSpan.className = style.luna ['searcher__pre']
        prefixSpan.innerHTML = prefix
        return prefixSpan

    __renderHighlights: (name, highlights) =>
        nameSpan = document.createElement 'span'
        last = 0
        highlights.forEach (highlight) =>
            normName = name.slice last, highlight.start
            highName = name.slice highlight.start, highlight.end
            last = highlight.end

            normSpan = document.createElement 'span'
            normSpan.innerHTML = normName
            nameSpan.appendChild normSpan

            highSpan = document.createElement 'span'
            highSpan.className = style.luna ['searcher__hl']
            highSpan.innerHTML = highName
            nameSpan.appendChild highSpan
        normSpan = document.createElement 'span'
        normSpan.innerHTML = name.slice last
        nameSpan.appendChild normSpan
        return nameSpan

    #######################
    ### Adjust the view ###
    #######################

    adjust: (view) =>
        console.log "Searcher : adjust"
        if @changed.position
            @__withParentNode (parentNode) =>
                [posx, posy] = @model.position.slice()
                exprPosY = parentNode.view('text').position.y
                # view.position.xy = [searcherBaseOffsetX + posx, searcherBaseOffsetY + exprPosY + posy]

    __withParentNode: (f) =>
        unless @parentNode?
            if @parent.node?
                @parentNode = @parent.node @model.key
            else
                @parentNode = @parent

        unless @parentNode?
            @warn "Trying to perform an action on an unknown parent"

        f @parentNode

    __offsetFromNode: => [searcherBaseOffsetX, searcherBaseOffsetY]

    __onPositionChanged: (parentNode) =>
        @set position: parentNode.model.position

    ###################################
    ### Register the event handlers ###
    ###################################

    registerEvents: =>
        @__withParentNode (parentNode) =>
            @__onPositionChanged parentNode
            @addDisposableListener parentNode, 'position', =>
                @__onPositionChanged parentNode

        @dom.input.addEventListener 'input', (e) =>
            @pushEvent
                tag: 'SearcherEditEvent'
                editSelectionStart: @dom.input.selectionStart
                editSelectionEnd:   @dom.input.selectionEnd
                editValue:          @dom.input.value
        @dom.input.addEventListener 'keyup', (e) =>
            if e.code == 'Enter'
                @pushEvent
                    tag: 'SearcherAcceptEvent'
                    acceptSelectionStart: @dom.input.selectionStart
                    acceptSelectionEnd:   @dom.input.selectionEnd
                    acceptValue:          @dom.input.value