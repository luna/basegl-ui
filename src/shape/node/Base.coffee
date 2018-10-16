import * as basegl from 'basegl'
import {circle}    from 'basegl/display/Shape'


export width = (style) -> style.node_radius * 2 + style.node_selectionBorderMaxSize * 2
export height = (style) -> style.node_radius * 2 + style.node_selectionBorderMaxSize * 2

export compactNodeExpr = (style) -> basegl.expr ->
    r1     = style.node_radius
    node   = circle r1
    node   = node.move width(style)/2, height(style)/2
