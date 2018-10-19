import {ContainerComponent}   from 'abstract/ContainerComponent'
import {BreadcrumbArrowShape} from 'shape/BreadcrumbArrow'
import {RectangleShape}       from 'shape/Rectangle'
import * as color             from 'shape/Color'
import {Widget}               from 'widget/Widget'

export class BreadcrumbArrow extends Widget
    initModel: =>
        model = super()
        model.frameColor = color.placeholder
        model.arrowColor = color.placeholder
        model.roundFrame = 0
        model

    prepare: =>
        @__minWidth = @style.breadcrumb_arrowWidth
        @addDef 'arrow', BreadcrumbArrowShape
        @addDef 'box', RectangleShape

    update: =>
        if @changed.height or @changed.width or @changed.border
            @updateDef 'box',
                height: @model.height
                width:  @model.width

        if @changed.frameColor
            @updateDef 'box', color: @model.frameColor

        if @changed.arrowColor
            @updateDef 'arrow', color: @model.arrowColor

        if @changed.roundFrame or @changed.siblings
            @updateDef 'box',
                corners:
                    topLeft    : @model.siblings.top    or @model.siblings.left
                    topRight   : @model.siblings.top    or @model.siblings.right
                    bottomLeft : @model.siblings.bottom or @model.siblings.left
                    bottomRight: @model.siblings.bottom or @model.siblings.right
                    round: @model.roundFrame
    adjust: =>
        if @changed.height
            @view('arrow').position.y = -@model.height/2
            @view('box').position.y = -@model.height
