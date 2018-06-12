import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {Component}    from 'view/Component'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path
    , plane, triangle} from 'basegl/display/Shape'
import {vector}       from 'basegl/math/Vector'


#### basic shapes ####

white          = Color.rgb [1,1,1]
bg             = (Color.hsl [40,0.08,0.09]).toRGB()
selectionColor = bg.mix (Color.hsl [50, 1, 0.6]), 0.8
nodeBg         = bg.mix white, 0.04

nodeRadius     = 30
gridElemOffset = 18
arrowOffset    = gridElemOffset + 2
export nodeSelectionBorderMaxSize = 40

export width = nodeRadius * 2 + nodeSelectionBorderMaxSize * 2
export height = nodeRadius * 2 + nodeSelectionBorderMaxSize * 2
export slope = 20

export togglerSize = 10 
export togglerButtonShape = basegl.expr ->
    triangle(togglerSize, togglerSize)
        .fill white
        .moveX togglerSize/2        

basicNodeShape = -> basegl.expr ->
    border = 0
    r1     = nodeRadius + border
    node   = circle r1
    node   = node.move width/2, height/2

basicExpandedNodeShape = -> basegl.expr ->
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

#### shapes with frames and selections ####

export compactNodeShape = basegl.expr ->
    node = basicNodeShape()
    node   = node.fill nodeBg

    eye    = 'scaledEye.z'
    border = node.grow(Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.7)).grow(-1)

    sc     = selectionColor.copy()
    sc.a   = 'selected'
    border = border.fill sc

    border + node

export expandedNodeShape = basegl.expr ->
    node   = basicExpandedNodeShape()
    node   = node.fill nodeBg

    eye    = 'scaledEye.z'
    border = node.grow(Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.7)).grow(-1)

    sc     = selectionColor.copy()
    sc.a   = 'selected'
    border = border.fill sc

    border + node

#### error frames ####

errorFrame = 20.0
export errorWidth = width + errorFrame
export errorHeight = height + errorFrame
stripeWidth = 30.0
rotation = Math.PI * 3 / 4
start = errorFrame/3

export expandedNodeErrorShape = basegl.expr ->
    frame = basicExpandedNodeShape().grow 20
           .fill Color.rgb [1,0,0]
    stripe = rect 1000, stripeWidth
            .repeat vector(0, 1), stripeWidth
            .move 0, start
            .rotate rotation
    frame * stripe


export compactNodeErrorShape = basegl.expr ->
    frame = basicNodeShape().grow errorFrame
           .fill Color.rgb [1,0,0]
    stripe = rect 1000, stripeWidth
            .repeat vector(0, 1), stripeWidth
            .move 0, start
            .rotate rotation
    frame * stripe
