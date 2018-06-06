import * as basegl  from 'basegl'
import * as Color   from 'basegl/display/Color'
import {group}      from 'basegl/display/Symbol'
import {Composable} from 'basegl/object/Property'

import * as shape       from 'shape/Port'
import * as nodeShape   from 'shape/Node'
import * as util        from 'shape/util'
import {Component}      from 'view/Component'


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
        @redraw()

    destruct: =>
        for own k, subport of @subports
            subport.dispose?()
        @subport?.dispose?()

export class InPort extends Subports
    updateModel: ({ key:      @key      = @key
                  , name:      name     = @name
                  , angle:    @angle    = @angle
                  , mode:     @mode     = @mode or 'in'
                  , locked:   @locked   = @locked or false
                  , position:  position = @position or [0,0]
                  , radius:   @radius   = @radius or 0
                  , color:    @color    = @color or [0, 1, 0]
                  , widgets:  @widgets  = @widgets or []
                  }) =>
        @emitProperty 'position', position
        if @mode == 'self'
            if @subport?
                @subport.redraw()
            else
                @subport = new Self {}, @
                @subport.attach()
        else if not @locked and @subports? and (Object.keys @subports).length
            if @subport?
                @subport.dispose()
                delete @subport
            for own k, subport of @subports
                if subport.component?
                    subport.component.set angle: subport.angle
                else
                    inArrow = new InArrow angle: subport.angle, @
                    inArrow.set angle: subport.angle
                    subport.component = inArrow
                    inArrow.attach()
        else
            if @subport?
                @subport.redraw()
            else
                @subport = new InArrow angle: @angle, @
                @subport.attach()

export class OutPort extends Subports
    updateModel: ({ key:     @key      = @key
                  , angle:   @angle    = @angle
                  , position: position = @position or [0,0]
                  , radius:  @radius   = @radius or 0
                  , color:   @color    = @color or [0, 1, 0]
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

class Self extends Port
    updateModel: =>
        unless @def?
            @def = selfPortShape

    updateView: =>
        @group.position.xy = @parent.position
        @view.position.xy = [-shape.selfPortWidth/2, -shape.selfPortHeight/2]
        @view.variables.color_r = @parent.color[0]
        @view.variables.color_g = @parent.color[1]
        @view.variables.color_b = @parent.color[2]

inPortShape = basegl.symbol shape.inPortShape
inPortShape.bbox.xy = [shape.width,shape.length]
inPortShape.variables.color_r = 1
inPortShape.variables.color_g = 0
inPortShape.variables.color_b = 0
nameOffset = shape.width

class InArrow extends Port
    updateModel: ({ angle: @angle = @angle
                  }) =>
        unless @def? and @name == @parent.name
            @name = @parent.name
            nameDef = util.text str: @name
            @def = [{ name: 'port', def: inPortShape }
                   ,{ name: 'name', def: nameDef }
                   ]
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
        @view.name.position.xy = [- nameSize[0] - nameOffset - shape.length - @radius, -nameSize[1]/2]


outPortShape = basegl.symbol shape.outPortShape
outPortShape.bbox.xy = [shape.width,shape.length]
outPortShape.variables.color_r = 1
outPortShape.variables.color_g = 0
outPortShape.variables.color_b = 0

class OutArrow extends Port
    updateModel: ({ angle: @angle = @angle
                  }) =>
        unless @def?
            @def = outPortShape

    updateView: =>
        @group.position.xy = @parent.position
        @view.position.xy = [-shape.width/2, @parent.radius]
        rotation = @angle
        @view.rotation.z = rotation
        @view.variables.color_r = @parent.color[0]
        @view.variables.color_g = @parent.color[1]
        @view.variables.color_b = @parent.color[2]


flatPortShape = basegl.symbol shape.flatPortShape
flatPortShape.bbox.xy = [shape.length, shape.width]
flatPortShape.variables.color_r = 1
flatPortShape.variables.color_g = 0
flatPortShape.variables.color_b = 0

export class FlatPort extends Subports
    constructor: (args...) ->
        super(args...)
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
