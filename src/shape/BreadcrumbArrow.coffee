import * as basegl         from 'basegl'
import * as color          from 'shape/Color'
import {triangle} from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers         from 'view/layers'


arrowExpr = (style) -> basegl.expr ->
    activeArea = triangle style.breadcrumb_arrowHeight, style.breadcrumb_arrowWidth
        .rotate Math.PI/2
        .moveY style.breadcrumb_arrowHeight/2
        .fill color.varAlpha style

arrowSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol arrowExpr style
    symbol.bbox.xy = [style.breadcrumb_arrowWidth, style.breadcrumb_arrowHeight]
    symbol.variables.color_r = 0
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.color_a = 1
    symbol.defaultZIndex = layers.breadcrumbArrow
    symbol

export class BreadcrumbArrowShape extends BasicComponent
    initModel: =>
        color: color.placeholder
    define: => arrowSymbol @style
    adjust: (element) =>
        if @changed.once
            element.position.y = -@style.breadcrumb_arrowHeight/2
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
            element.variables.color_a = @model.color[3] or 1
