import {ConnectionShape}    from 'shape/Connection'
import {ContainerComponent} from 'abstract/ContainerComponent'


export class HalfConnection extends ContainerComponent
    initModel: =>
        key: 'halfconnection'
        srcNode: null
        srcPort: null
        dstPos: [0,0]
        reversed: false

    prepare: =>
        @addDef 'connection', new ConnectionShape null, @

    update: =>
        if @changed.srcNode or @changed.srcPort or @changed.reversed
            @__rebind()
        if @changed.dstPos
            @__onPositionChange()

    connectSources: =>
        @__onColorChange()
        @__onPositionChange()
        @addDisposableListener @srcPort, 'color', (color) => @__onColorChange()
        @addDisposableListener @srcNode, 'position', => @__onPositionChange()
        @addDisposableListener @srcPort, 'position', => @__onPositionChange()
        ports = if @model.reversed then 'inPorts' else 'outPorts'
        @addDisposableListener @srcNode.def(ports),  'modelUpdated', => @__rebind()

        @onDispose => @srcPort.unfollow @model.key
        @withScene (scene) =>
            @addDisposableListener window, 'mousemove', (e) =>
                campos = scene.camera.position
                y = scene.height/2 + campos.y + (-scene.screenMouse.y + scene.height/2) * campos.z
                x = scene.width/2  + campos.x + (scene.screenMouse.x - scene.width/2) * campos.z
                @set dstPos: [x, y]

    __rebind: =>
        srcNode = @parent.node @model.srcNode
        srcPort =
            if @model.reversed
                srcNode.inPort @model.srcPort
            else
                srcNode.outPort @model.srcPort

        if @srcNode != srcNode or @srcPort != srcPort
            @fireDisposables()
            @srcNode = srcNode
            @srcPort = srcPort
            @connectSources()

    __onPositionChange: =>
        srcPos = @srcPort.connectionPosition()
        leftOffset = @srcPort.model.radius

        x = @model.dstPos[0] - srcPos[0]
        y = @model.dstPos[1] - srcPos[1]
        length = Math.sqrt(x*x + y*y) - leftOffset
        rotation = Math.atan2 y, x

        @def('connection').set
            offset: leftOffset
            length: length
            angle: rotation

        @view('connection').position.xy = srcPos.slice()
        @srcPort.follow @model.key, rotation - Math.PI/2

    __onColorChange: =>
        @def('connection').set color: @srcPort.model.color
