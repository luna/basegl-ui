import * as basegl  from 'basegl'
import * as Color   from 'basegl/display/Color'
import {group}      from 'basegl/display/Symbol'
import {Composable} from 'basegl/object/Property'

import * as shape       from 'shape/Port'
import * as nodeShape   from 'shape/Node'
import * as util        from 'shape/util'
import {Component}      from 'view/Component'
import * as layers      from 'view/layers'


class Port extends Component
    registerEvents: =>
        @group.addEventListener 'mousedown', @pushEvent
        @group.addEventListener 'mouseup',  @pushEvent

class Subports extends Component
    constructor: (args...) ->
        super args...

    follow: (key, angle) =>
        @subports ?= {}
        if @subports[key]?
            @subports[key].angle = angle
        else
            @subports[key] = angle: angle
        @redraw()

    unfollow: (key) =>
        @subports[key].component?.dispose()
        delete @subports[key]
        @redraw() unless @disposed

    destruct: =>
        for own k, subport of @subports
            subport.dispose?()
        @subport?.dispose?()

export class InPort extends Subports
    updateModel: ({ key:      @key      = @key
                  , name:     @name     = @name or ''
                  , typeName: @typeName = @typeName or ''
                  , angle:    @angle    = @angle
                  , mode:     @mode     = @mode or 'in'
                  , locked:   @locked   = @locked or false
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , color:    @color    = @color or [0, 1, 0]
                  , widgets:  @widgets  = @widgets or []
                  }) =>
        @emitProperty 'position', position
        cons = if @mode == 'self' then Self else InArrow
        if not @locked and @subports? and (Object.keys @subports).length
            if @subport?
                @subport.dispose()
                delete @subport
            for own k, subport of @subports
                if subport.component?
                    subport.component.set angle: subport.angle
                else
                    inArrow = new cons angle: subport.angle, @
                    inArrow.set angle: subport.angle
                    subport.component = inArrow
                    inArrow.attach()
        else
            if @subport?
                @subport.redraw()
            else
                @subport = new cons angle: @angle, @
                @subport.attach()

export class OutPort extends Subports
    updateModel: ({ key:      @key      = @key
                  , typeName: @typeName = @typeName or ''
                  , angle:    @angle    = @angle
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , color:    @color    = @color or [0, 1, 0]
                  }) =>
        @emitProperty 'position', position
        if @subports? and (Object.keys @subports).length
            if @subport?
                @subport.dispose()
                delete @subport
            for own k, subport of @subports
                if subport.component?
                    subport.component.set angle: subport.angle
                else
                    outArrow = new OutArrow angle: subport.angle, @
                    subport.component = outArrow
                    outArrow.attach()
        else unless @subport?
            @subport = new OutArrow angle: @angle, @
            @subport.attach()

selfPortShape = basegl.symbol shape.selfPortShape
selfPortShape.bbox.xy = [shape.selfPortWidth, shape.selfPortHeight]
selfPortShape.variables.color_r = 1
selfPortShape.variables.color_g = 0
selfPortShape.variables.color_b = 0
selfPortShape.defaultZIndex = layers.selfPort

class Self extends Port
    updateModel: ({ angle: @angle = @angle }) =>
        unless @def? and @typeName == @parent.typeName and @hovered == @parent.parent.hovered
            @typeName = @parent.typeName
            @hovered  = @parent.parent.hovered
            @def = [{ name: 'port', def: selfPortShape}]
            if @hovered
                @def.push
                    name: 'typeName'
                    def: util.text str: @typeName
            if @view?
                @reattach()

    updateView: =>
        @group.position.xy = @parent.position
        @view.port.position.xy = [-shape.selfPortWidth/2, -shape.selfPortHeight/2]
        @view.port.variables.color_r = @parent.color[0]
        @view.port.variables.color_g = @parent.color[1]
        @view.port.variables.color_b = @parent.color[2]
        if @view.typeName?
            rotation = @angle
            @view.typeName.rotation.z = rotation - Math.PI/2
            typeNameSize = util.textSize @view.typeName
            typeNamePosition = [- typeNameSize[0] - typeNameXOffset - @parent.radius, - typeNameSize[1]/2]
            @view.typeName.position.xy = typeNamePosition

inPortShape = basegl.symbol shape.inPortShape
inPortShape.bbox.xy = [shape.width,shape.length]
inPortShape.variables.color_r = 1
inPortShape.variables.color_g = 0
inPortShape.variables.color_b = 0
inPortShape.defaultZIndex = layers.inPort

nameXOffset = shape.length * 2
typeNameXOffset = nameXOffset
typeNameYOffset = nameXOffset

class InArrow extends Port
    updateModel: ({ angle: @angle = @angle
                  }) =>
        unless @def? and @name == @parent.name and @hovered == @parent.parent.hovered and @typeName == @parent.typeName
            @name     = @parent.name
            @hovered  = @parent.parent.hovered
            @typeName = @parent.typeName
            nameDef = util.text str: @name
            @def = [{ name: 'port', def: inPortShape }
                   ,{ name: 'name', def: nameDef }
                   ]
            if @hovered
                @def.push
                    name: 'typeName'
                    def: util.text str: @typeName
            if @view?
                @reattach()

    updateView: =>
        @group.position.xy =
            if @parent.locked
                [@parent.position[0] + shape.length, @parent.position[1]]
            else
                @parent.position
        @view.port.position.xy = [-shape.width/2, @parent.radius]
        @view.port.variables.color_r = @parent.color[0]
        @view.port.variables.color_g = @parent.color[1]
        @view.port.variables.color_b = @parent.color[2]
        rotation = @angle
        @view.port.rotation.z = rotation
        nameSize = util.textSize @view.name
        @view.name.rotation.z = rotation - Math.PI/2
        namePosition = [- nameSize[0] - nameXOffset - @parent.radius, -nameSize[1]/2]
        @view.name.position.xy = namePosition
        if @view.typeName?
            @view.typeName.rotation.z = rotation - Math.PI/2
            typeNameSize = util.textSize @view.typeName
            typeNamePosition = [- typeNameSize[0] - typeNameXOffset - @parent.radius, - typeNameSize[1] - typeNameYOffset]
            @view.typeName.position.xy = typeNamePosition


outPortShape = basegl.symbol shape.outPortShape
outPortShape.bbox.xy = [shape.width,shape.length]
outPortShape.variables.color_r = 1
outPortShape.variables.color_g = 0
outPortShape.variables.color_b = 0
outPortShape.defaultZIndex = layers.outPort

class OutArrow extends Port
    updateModel: ({ angle: @angle = @angle
                  }) =>
        unless @def? and @hovered == @parent.parent.hovered
            @hovered = @parent.parent.hovered
            @def = [{name: 'port', def: outPortShape}]
            if @hovered
                @def.push
                    name: 'typeName'
                    def: util.text str: @parent.typeName
        if @view?
            @reattach()

    updateView: =>
        @group.position.xy = @parent.position
        @view.port.position.xy = [-shape.width/2, @parent.radius]
        rotation = @angle
        @view.port.rotation.z = rotation
        @view.port.variables.color_r = @parent.color[0]
        @view.port.variables.color_g = @parent.color[1]
        @view.port.variables.color_b = @parent.color[2]
        if @view.typeName?
            @view.typeName.rotation.z = rotation + Math.PI/2
            typeNameSize = util.textSize @view.typeName
            typeNamePosition = [typeNameSize[0] + nameXOffset + @parent.radius, -typeNameSize[1]/2]
            @view.typeName.position.xy = typeNamePosition


flatPortShape = basegl.symbol shape.flatPortShape
flatPortShape.bbox.xy = [shape.length, shape.width]
flatPortShape.variables.color_r = 1
flatPortShape.variables.color_g = 0
flatPortShape.variables.color_b = 0
flatPortShape.defaultZIndex = layers.flatPort

export class FlatPort extends Subports
    constructor: (args...) ->
        super args...
        @output ?= false

    updateModel: ({ key:      @key      = @key
                  , name:      name     = @name
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , output:   @output   = @output
                  , color:    @color    = @color or [0, 1, 0]
                  }) =>
        @emitProperty 'position', position
        unless @def? and @name == name
            @name = name
            nameDef = util.text str: @name
            @def = [{ name: 'port', def: flatPortShape }
                   ,{ name: 'name', def: nameDef }
                   ]
            if @view?
                @reattach()

    updateView: =>
        x = if @output then @position[0] else @position[0] - shape.length
        @group.position.xy = [x, @position[1] - shape.width/2]
        nameHeight = util.textHeight @view.name
        @view.name.position.xy = [2* shape.length, nameHeight/2]
        @view.port.variables.color_r = @color[0]
        @view.port.variables.color_g = @color[1]
        @view.port.variables.color_b = @color[2]
