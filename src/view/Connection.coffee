import * as basegl    from 'basegl'
import {group}        from 'basegl/display/Symbol'
import {Composable}   from "basegl/object/Property"

import * as shape       from 'shape/Connection'
import * as nodeShape   from 'shape/Node'
import * as portShape   from 'shape/Port'
import * as layers      from 'view/layers'
import {Component}  from 'view/Component'
import {InputNode}  from 'view/InputNode'
import {OutputNode} from 'view/OutputNode'


connectionShape = basegl.symbol shape.connectionShape
connectionShape.defaultZIndex = layers.connection
connectionShape.bbox.y = shape.width
connectionShape.variables.color_r = 1
connectionShape.variables.color_g = 0
connectionShape.variables.color_b = 0

export class Connection extends Component
    constructor: (args...) ->
        super args...
        @srcNodeSubscirbed = false
        @dstNodeSubscribed = false
        @disposables = []

    updateModel: ({ key: @key = @key
                  , srcNode: @srcNode = @srcNode
                  , srcPort: @srcPort = @srcPort
                  , dstNode: @dstNode = @dstNode
                  , dstPort: @dstPort = @dstPort
                  }) =>
        unless @def?
            @def =  [
                        name: 'src'
                        def: connectionShape
                    ,
                        name: 'dst'
                        def: connectionShape
                    ]
    updateView: =>
        srcNode = @parent.node @srcNode
        dstNode = @parent.node @dstNode
        return unless srcNode? and dstNode?
        srcPort = srcNode.outPorts[@srcPort]
        dstPort = dstNode.inPorts[@dstPort]
        return unless srcPort? and dstPort?
        @connectSources srcPort, dstPort
        srcPos = srcPort.position
        dstPos = dstPort.position
        if srcNode instanceof InputNode
            leftOffset = srcPort.radius
        else
            leftOffset = srcPort.radius + 1/2*portShape.length
        rightOffset = dstPort.radius

        x = dstPos[0] - srcPos[0]
        y = dstPos[1] - srcPos[1]
        length = Math.sqrt(x*x + y*y) - leftOffset - rightOffset
        rotation = Math.atan2 y, x
        @view.src.position.x = leftOffset
        @view.src.position.y = -shape.width/2
        @element.src.bbox.x = length/2
        @view.dst.position.x = leftOffset + length/2
        @view.dst.position.y = -shape.width/2
        @element.dst.bbox.x = length/2
        @group.position.xy = [srcPos[0], srcPos[1]]
        @view.src.rotation.z = rotation
        @view.dst.rotation.z = rotation
        srcPort.follow @key, rotation - Math.PI/2
        dstPort.follow @key, rotation + Math.PI/2

        @element.src.variables.color_r = srcPort.color[0]
        @element.src.variables.color_g = srcPort.color[1]
        @element.src.variables.color_b = srcPort.color[2]
        @element.dst.variables.color_r = srcPort.color[0]
        @element.dst.variables.color_g = srcPort.color[1]
        @element.dst.variables.color_b = srcPort.color[2]

    connectSources: (srcPort, dstPort) =>
        unless @srcConnected
            @addDisposableListener srcPort, 'position', => @updateView()
            @onDispose => srcPort.unfollow @key
            @srcConnected = true
        unless @dstConnected
            @addDisposableListener dstPort, 'position', => @updateView()
            @onDispose => dstPort.unfollow @key
            @dstConnected = true

    registerEvents: =>
        @view.src.addEventListener 'mousedown', => @pushEvent
            tag: 'DisconnectEvent'
            src: true
        @view.dst.addEventListener 'mousedown', => @pushEvent
            tag: 'DisconnectEvent'
            src: false
