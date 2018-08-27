import {HtmlShape} from 'shape/Html'
import * as layers from 'view/layers'
import * as style  from 'style'
import {Widget}    from 'widget/Widget'


export class TextInput extends Widget
    initModel: ->
        model = super()
        model.value = ''
        model

    prepare: =>
        @addDef 'root', HtmlShape, element: 'div'

    update: =>
        if @changed.once
            @input = document.createElement 'input'
            @input.className = 'native-key-bindings ' + style.luna ['ctrl--text']
            @def('root').getDomElement().appendChild @input
        if @changed.width
            @input.style.width = @model.width + 'px'
        if @changed.height
            @input.style.height = @model.height + 'px'
        if @changed.siblings or @changed.height
            topLeft     = unless (@model.siblings.top    or @model.siblings.left ) then @model.height/2 else 0
            topRight    = unless (@model.siblings.top    or @model.siblings.right) then @model.height/2 else 0
            bottomLeft  = unless (@model.siblings.bottom or @model.siblings.left ) then @model.height/2 else 0
            bottomRight = unless (@model.siblings.bottom or @model.siblings.right) then @model.height/2 else 0
            @input.style.borderRadius = topLeft + 'px ' + topRight + 'px ' + bottomRight + 'px ' + bottomLeft + 'px'
        if @changed.value
            @input.value = @model.value

    adjust: (view) =>
        @view('root').position.xy = [@model.width/2, 0]

    registerEvents: (view) =>
        @input.addEventListener 'input', (e) =>
            @pushEvent
                tag: 'PortControlEvent'
                content:
                    cls: 'Text'
                    value: @input.value
