import * as basegl    from 'basegl'
import {Component}    from 'abstract/Component'
import {circle, glslShape, rect} from 'basegl/display/Shape'

#### basic shapes ####

export nodeRadius = 30
gridElemOffset    = 18
arrowOffset       = gridElemOffset + 2
export nodeSelectionBorderMaxSize = 40

export width = nodeRadius * 2 + nodeSelectionBorderMaxSize * 2
export height = nodeRadius * 2 + nodeSelectionBorderMaxSize * 2
export slope = 20

export compactNodeExpr = -> basegl.expr ->
    border = 0
    r1     = nodeRadius + border
    node   = circle r1
    node   = node.move width/2, height/2

export expandedNodeExpr = -> basegl.expr ->
    border       = 0
    bodyWidth    = 'bodyWidth'
    bodyHeight   = 'bodyHeight'
    headerOffset = arrowOffset
    r1    = nodeRadius + border
    r2    = nodeRadius + headerOffset + slope - border
    dy    = slope
    dx    = Math.sqrt ((r1+r2)*(r1+r2) - dy*dy)
    angle = Math.atan(dy/dx)

    maskPlane     = glslShape("-sdf_halfplane(p, vec2(1.0,0.0));").moveX(dx)
    maskRect      = rect(r1+r2, r2 * Math.cos(-angle)).alignedTL.rotate(-angle)
    mask          = (maskRect - maskPlane).inside
    headerShape   = (circle(r1) + mask) - circle(r2).move(dx,dy)
    headerFill    = rect(r1*2, nodeRadius + headerOffset + 10).alignedTL.moveX(-r1)
    header        = (headerShape + headerFill).move(nodeRadius,nodeRadius).moveY(headerOffset+bodyHeight)

    body          = rect(bodyWidth + 2*border, bodyHeight + 2*border, 0, nodeRadius).alignedBL
    node          = (header + body).move(nodeSelectionBorderMaxSize,nodeSelectionBorderMaxSize)
