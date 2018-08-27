import {BasicComponent} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'

export width     = 30

lineWidth = 2

export rectangleExpr = basegl.expr ->
    rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.varAlpha()

rectangleSymbol = basegl.symbol rectangleExpr
rectangleSymbol.defaultZIndex = layers.textFrame
rectangleSymbol.variables.color_r = 1
rectangleSymbol.variables.color_g = 0
rectangleSymbol.variables.color_b = 0
rectangleSymbol.variables.color_a = 0

export class RectangleShape extends BasicComponent
    initModel: =>
        width: 0
        height: 0
        color: null

    define: =>
        rectangleSymbol

    adjust: (element, view) =>
        if @changed.width
            element.bbox.x = @model.width
        if @changed.height
            element.bbox.y = @model.height
        if @changed.color
            element.variables.color_a = Number @model.color?
            if @model.color?
                element.variables.color_r = @model.color[0]
                element.variables.color_g = @model.color[1]
                element.variables.color_b = @model.color[2]
