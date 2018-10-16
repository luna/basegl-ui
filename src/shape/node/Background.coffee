import * as basegl from 'basegl'
import {rect}      from 'basegl/display/Shape'

import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import {ContainerComponent}             from 'abstract/ContainerComponent'
import {nodeBg}                         from 'shape/Color'
import * as layers                      from 'view/layers'
import {shadowExpr}                     from 'shape/Shadow'


baseExpr = (style) -> basegl.expr ->
    bodyHeight   = 'bbox.y' - 2 * style.node_shadowRadius
    bodyWidth    = 'bbox.x' - 2 * style.node_shadowRadius
    radiusTop = style.node_radius * 'roundTop'
    radiusBottom = style.node_radius * 'roundBottom'
    rect bodyWidth, bodyHeight, radiusTop, radiusTop, radiusBottom, radiusBottom

backgroundExpr = (style) -> basegl.expr ->
    base = baseExpr style
    background = base.fill nodeBg style
        .moveX 'invisible' * 'bbox.x'
        .move('bbox.x'/2, 'bbox.y'/2)

backgroundShadowExpr = (style) -> basegl.expr ->
    base = baseExpr style
    shadow = shadowExpr base, style.node_shadowRadius, style
        .move('bbox.x'/2, 'bbox.y'/2)

backgroundBaseSymbol = (expr, zIndex) -> memoizedSymbol (style) ->
    symbol = basegl.symbol expr style
    symbol.defaultZIndex = zIndex
    symbol.variables.invisible = 0
    symbol.variables.roundTop = 0
    symbol.variables.roundBottom = 0
    symbol

class BaseShape extends BasicComponent
    initModel: =>
        width: null
        height: null
        invisible: false
        roundTop: null
        roundBottom: null
    adjust: (element) =>
        if @changed.width
            element.position.x = - @style.node_shadowRadius
            element.bbox.x = @model.width + 2 * @style.node_shadowRadius
        if @changed.height
            element.position.y = - @model.height - @style.node_shadowRadius
            element.bbox.y = @model.height + 2 * @style.node_shadowRadius
        if @changed.invisible
            element.variables.invisible = Number @model.invisible
        if @changed.roundBottom
            @animateVariable 'roundBottom', Number @model.roundBottom
        if @changed.roundTop
            @animateVariable 'roundTop', Number @model.roundTop

class ShadowShape extends BaseShape
    define: => backgroundBaseSymbol(backgroundShadowExpr, layers.shadow)(@style)

class BackgroundShape extends BaseShape
    define: => backgroundBaseSymbol(backgroundExpr, layers.nodeModule)(@style)

export class Background extends ContainerComponent
    initModel: =>
        width: null
        height: null
        invisible: false
        roundTop: null
        roundBottom: null
    prepare: =>
        @addDef 'background', BackgroundShape
        @addDef 'shadow',     ShadowShape
    update: =>
        @updateDef 'background',
            width: @model.width
            height: @model.height
            invisible: @model.invisible
            roundTop: @model.roundTop
            roundBottom: @model.roundBottom
        @updateDef 'shadow',
            width: @model.width
            height: @model.height
            invisible: @model.invisible
            roundTop: @model.roundTop
            roundBottom: @model.roundBottom
