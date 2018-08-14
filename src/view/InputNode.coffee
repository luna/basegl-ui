import {ContainerComponent} from 'abstract/ContainerComponent'
import * as basegl          from 'basegl'
import {AddPortShape}       from 'shape/port/Add'
import * as portShape       from 'shape/port/Base'
import {FlatPort}           from 'view/port/Flat'
import {SetView}            from 'view/SetView'


height = 100


export class InputNode extends ContainerComponent
    initModel: =>
        key: null
        outPorts: {}
        position: [0, 0]

    prepare: =>
        @addDef 'add', new AddPortShape null, @
        @addDef 'outPorts', new SetView cons: FlatPort, @

    update: =>
        return unless @changed.outPorts
        i = 0
        keys = Object.keys @model.outPorts
        portOffset = height / keys.length
        newPosition = =>
            pos = [ 0 , 0 + portOffset * keys.length - i * portOffset]
            i++
            return pos
        for own k, outPort of @model.outPorts
            outPort.position = newPosition()
            outPort.output = false
        @updateDef 'outPorts', elems: @model.outPorts
        @addPortPosition = newPosition()

    adjust: (view) =>
        if @changed.outPorts
            @view('add').position.xy = [
                @addPortPosition[0], @addPortPosition[1]
            ]

        if @changed.position
            view.position.xy = @model.position.slice()

    _align: (scene) =>
        campos = scene.camera.position
        x = scene.width/2 + campos.x - scene.width/2*campos.z
        y = scene.height/2 + campos.y - height/2
        @set position: [x, y]

    connectSources: =>
        @withScene (scene) =>
            @_align scene
            @addDisposableListener scene.camera, 'move', => @_align scene

    outPort: (key) => @def('outPorts').def(key)

    inPort: => undefined
