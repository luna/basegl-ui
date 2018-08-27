import {ContainerComponent} from 'abstract/ContainerComponent'
import {TextShape}          from 'shape/Text'
import {RectangleShape}     from 'shape/Rectangle'
import * as color           from 'shape/Color'
import {Widget}             from 'widget/Widget'

export class TextContainer extends Widget
    initModel: =>
        model = super()
        model.text = ''
        model.align = 'left'
        model.textAlign = 'left'
        model.frameColor = null
        model.border = 3
        model.onclick = =>
        model

    prepare: =>
        @addDef 'text', TextShape,
            text: @model.text
            align: 'left'
        @addDef 'box', RectangleShape,
            color: @model.frameColor

    update: =>
        if @changed.text
            @updateDef 'text', text: @model.text

        if @changed.text or @changed.height or @changed.width or @changed.border
            size = @def('text').size()
            @__minWidth  = size[0] + 2 * @model.border
            @__minHeight = size[1] + 2 * @model.border
            @updateDef 'box', height: @model.height or @__minHeight
            @updateDef 'box', width:  @model.width  or @__minWidth

        if @changed.frameColor
            @updateDef 'box', color: @model.frameColor

    adjust: =>
        if @changed.text or @changed.align or @changed.width or @changed.height
            height = @model.height or @__minHeight
            width  = @model.width or @__minWidth
            x = if @model.align == 'right'
                    -width
                else if @model.align == 'center'
                    -width/2
                else
                    0
            textX = if @model.textAlign == 'right'
                    x + width - @__minWidth
                else if @model.textAlign == 'center'
                    x + (width - @__minWidth)/2
                else
                    x

            @view('text').position.x = textX + @model.border
            @view('box').position.xy = [x, -height/2]

    registerEvents: (view) =>
        view.addEventListener 'click', (e) =>
            @model.onclick e
