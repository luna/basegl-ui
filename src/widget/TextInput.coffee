import {HtmlShape}      from 'shape/Html'
import {RectangleShape} from 'shape/Rectangle'
import * as style       from 'style'
import * as layers      from 'view/layers'
import {Widget}         from 'widget/Widget'


export class TextInput extends Widget
    initModel: ->
        model = super()
        model.value = ''
        model.color = null
        model.frameColor = [@style.bgColor_h, @style.bgColor_s, @style.bgColor_l]
        model

    prepare: =>
        @addDef 'root', HtmlShape, element: 'div'
        @input = document.createElement 'input'
        @input.className = 'native-key-bindings'
        @input.style.background = 'none'
        @input.style.border = 'none'
        @input.style.outline = 'none'
        @def('root').getDomElement().appendChild @input
        @addDef 'background', RectangleShape,
            color: @model.frameColor
    update: =>
        if @changed.once
            @input = document.createElement 'input'
            @input.className = 'native-key-bindings ' + style.luna ['ctrl--text']
            @def('root').getDomElement().appendChild @input
        
        return unless @input?
        if @changed.width
            @input.style.width = @model.width + 'px'
        if @changed.height
            @input.style.height = @model.height + 'px'
        if @changed.value
            @input.value = @model.value
        if @changed.color
            @input.style.color = @model.color

    adjust: (view) =>
        @view('root').position.xy = [@model.width/2, 0]
        @view('background').position.y = -@model.height/2

    registerEvents: (view) =>
        @input.addEventListener 'input', (e) =>
            @pushEvent
                tag: 'PortControlEvent'
                content:
                    cls: 'Text'
                    value: @input.value
