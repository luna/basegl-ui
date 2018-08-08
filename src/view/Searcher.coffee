import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape} from 'shape/Html'

import * as basegl from 'basegl'
import * as style  from 'style'
import * as shape  from 'shape/node/Base'


searcherRoot    = 'searcher-root'


export class Searcher extends ContainerComponent

    ################################
    ### Initialize the component ###
    ################################

    initModel: =>
        key: null
        input: null
        inputSelection: null
        selected: 0
        entries: []
        position: [0, 0]
        parent: null

    prepare: =>
        @dom = {}
        @addDef 'root', new HtmlShape
                element: 'div'
                id: 'searcher-root'
                scalable: false
            , @

    #############################
    ### Create/update the DOM ###
    #############################

    __anyChanged: =>
        @changed.entries or @changed.input or @changed.inputSelection or @changed.selected

    update: =>
        @__createDom() unless @dom.container?
        if @__anyChanged()
            @__updateResults()
            @__updateInput()
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
        @dom.input.value = @model.input
        @dom.input.className = style.luna ['searcher__input']

    __updateResults: =>
        @dom.resultsList.innerText = ''
        return unless @model.entries.length > 0

        firstResult = @__renderResult @model.entries[0], @model.selected != 0
        @dom.resultsList.appendChild firstResult
        @model.entries[1..].forEach (entry) =>
            @dom.resultsList.appendChild @__renderResult entry, false

    __updateInput: =>
        inputClasses = ['searcher__input']
        inputClasses.push ['searcher__input-selected'] if @model.selected == 0
        inputClasses.push ['searcher__no-results'] if @model.entries.length == 0
        @dom.input.className = style.luna inputClasses
        @dom.input.value = @model.input
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

    ###################################
    ### Register the event handlers ###
    ###################################

    registerEvents: =>
        @dom.input.addEventListener 'input', (e) =>
            @pushEvent
                tag: 'SearcherEditEvent'
                editSelectionStart: @dom.input.selectionStart
                editSelectionEnd:   @dom.input.selectionEnd
                editValue:          @dom.input.value
        @dom.input.addEventListener 'keyup', (e) =>
            if e.key == 'Enter'
                @pushEvent
                    tag: 'SearcherAcceptEvent'
                    acceptSelectionStart: @dom.input.selectionStart
                    acceptSelectionEnd:   @dom.input.selectionEnd
                    acceptValue:          @dom.input.value
            else if e.key == 'Tab'
                @pushEvent tag: 'SeacherTabPressedEvent'

        @dom.input.addEventListener 'keydown', (e) =>
            if e.key == 'ArrowUp'
                @pushEvent tag: 'SearcherMoveUpEvent'
            else if e.key == 'ArrowDown'
                @pushEvent tag: 'SearcherMoveDownEvent'
