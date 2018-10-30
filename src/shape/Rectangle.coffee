import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'


export rectangleExpr = (style) -> basegl.expr ->
    corners = 'corners'
    topLeft = corners % 2
    corners = (corners - topLeft) / 2
    topRight = corners % 2
    corners = (corners - topRight) / 2
    bottomLeft = corners % 2
    corners = (corners - bottomLeft) / 2
    bottomRight = corners % 2
    corners = (corners - bottomRight) / 2
    topLeft = topLeft * corners
    topRight = topRight * corners
    bottomLeft = bottomLeft * corners
    bottomRight = bottomRight * corners
    rect ('bbox.x' -1), ('bbox.y'-1), topLeft, topRight, bottomLeft, bottomRight
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.varHSLAlpha style

rectangleSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol rectangleExpr style
    symbol.defaultZIndex = layers.textFrame
    symbol.variables.corners = 0
    symbol.variables.color_h = 0
    symbol.variables.color_s = 0
    symbol.variables.color_l = 0
    symbol.variables.color_a = 0
    symbol

export class RectangleShape extends BasicComponent
    initModel: =>
        width: 0
        height: 0
        color: null
        corners:
            topLeft: false
            topRight: false
            bottomLeft: false
            bottomRight: false
            round: 0

    define: =>
        rectangleSymbol @style

    adjust: (element, view) =>
        if @changed.width
            element.bbox.x = @model.width
        if @changed.height
            element.bbox.y = @model.height
        if @changed.color
            if @model.color?
                element.variables.color_h = @model.color[0]
                element.variables.color_s = @model.color[1]
                element.variables.color_l = @model.color[2]
            element.variables.color_a =
                unless @model.color?
                    0
                else if @model.color[3]?
                    @model.color[3]
                else
                    1
        if @changed.corners
            corners = @model.corners.round
            corners *= 2
            corners += @model.corners.bottomRight
            corners *= 2
            corners += @model.corners.bottomLeft
            corners *= 2
            corners += @model.corners.topRight
            corners *= 2
            corners += @model.corners.topLeft
            element.variables.corners = corners
