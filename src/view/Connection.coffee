import {ConnectionShape}    from 'shape/Connection'
import {ContainerComponent} from 'abstract/ContainerComponent'


export class Connection extends ContainerComponent
    initModel: =>
        key: null
        srcNode: null
        srcPort: null
        dstNode: null
        dstPort: null

    prepare: =>
        @addDef 'src', ConnectionShape, src: true
        @addDef 'dst', ConnectionShape, src: false

    update: =>
        if @changed.srcNode or @changed.srcPort
            @srcNode = @parent.node @model.srcNode
            @srcPort = @srcNode.outPort @model.srcPort
            @__onColorChange()
        if @changed.dstNode or @changed.dstPort
            @dstNode = @parent.node @model.dstNode
            @dstPort = @dstNode.inPort @model.dstPort
        if @changed.srcNode or @changed.srcPort or @changed.dstNode or @changed.dstPort
            @__onPositionChange()

    registerEvents: (view) =>
        registerDisconnect = (target, src) => @view(target).addEventListener 'mousedown', => @pushEvent
            tag: 'DisconnectEvent'
            src: src
        registerDisconnect 'src', true
        registerDisconnect 'dst', false

    connectSources: =>
        return unless @srcPort? and @dstPort?
        @__onColorChange()
        @__onPositionChange()
        @addDisposableListener @srcPort, 'color', => @__onColorChange()
        @addDisposableListener @srcNode, 'position', => @__onPositionChange()
        @addDisposableListener @dstNode, 'position', => @__onPositionChange()
        @addDisposableListener @dstPort, 'position', => @__onPositionChange()
        @onDispose => @srcPort.unfollow @model.key
        @onDispose => @dstPort.unfollow @model.key

    __onPositionChange: =>
        return unless @srcPort? and @dstPort?
        srcPos = @srcPort.connectionPosition()
        dstPos = @dstPort.connectionPosition()
        leftOffset = @srcPort.model.radius
        rightOffset = @dstPort.model.radius

        x = dstPos[0] - srcPos[0]
        y = dstPos[1] - srcPos[1]
        length = Math.sqrt(x*x + y*y) - leftOffset - rightOffset
        rotation = Math.atan2 y, x

        @def('src').set
            offset: leftOffset
            length: length/2
            angle: rotation
        @def('dst').set
            offset: leftOffset + length/2
            length: length/2
            angle: rotation
        @view('src').position.xy = srcPos.slice()
        @view('dst').position.xy = srcPos.slice()
        @srcPort.follow @model.key, rotation - Math.PI/2
        @dstPort.follow @model.key, rotation + Math.PI/2

    __onColorChange: =>
        @def('src').set color: @srcPort.model.color
        @def('dst').set color: @srcPort.model.color
