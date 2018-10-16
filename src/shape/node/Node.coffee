import * as basegl                      from 'basegl'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import {nodeBg, selectionColor}         from 'shape/Color'
import * as baseNode                    from 'shape/node/Base'
import {shadowExpr}                     from 'shape/Shadow'
import * as layers                      from 'view/layers'


compactNodeExpr = (style) -> basegl.expr ->
    base = baseNode.compactNodeExpr style
    node = base.fill nodeBg style
    shadow = shadowExpr base, style.node_shadowRadius, style
    eye  = 'scaledEye.z'
    selection = base.grow('selected' * Math.pow(Math.clamp(eye*style.node_selection_size, 0.0, 400.0),0.7)).grow(-1)
        .fill selectionColor style
    shadow + selection + node

compactNodeSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol compactNodeExpr style
    symbol.defaultZIndex = layers.compactNode
    symbol.variables.selected = 0
    symbol.bbox.xy = [baseNode.width(style), baseNode.height(style)]
    symbol

export class NodeShape extends BasicComponent
    initModel: =>
        selected: false
    define: => compactNodeSymbol @style
    adjust: (element) =>
        element.position.xy = [-baseNode.width(@style)/2, -baseNode.height(@style)/2]
        if @changed.selected
            @animateVariable 'selected', @model.selected
