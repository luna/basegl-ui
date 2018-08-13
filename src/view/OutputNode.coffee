import {ContainerComponent} from 'abstract/ContainerComponent'
import * as shape           from 'shape/port/Base'
import * as basegl          from 'basegl'
import {FlatPort}           from 'view/port/Flat'


height = 100


export class OutputNode extends ContainerComponent
    initModel: =>
        key:      null
        inPorts:  {}
        position: [0,0]

    update: =>
        return unless @changed.inPorts
        i = 0
        keys = Object.keys @model.inPorts
        portOffset = height / keys.length
        for key in keys
            inPort = @model.inPorts[key]
            inPort.position = [0, i * portOffset]
            inPort.output = true
            @autoUpdateDef ('in' + key), FlatPort, inPort
            i++
    adjust: (view) =>
        if @changed.position
            view.position.xy = @model.position.slice()

    _align: (scene) =>
        campos = scene.camera.position
        x = scene.width/2 + campos.x + scene.width/2*campos.z
        y = scene.height/2 + campos.y - height/2
        @set position: [x, y]

    connectSources: =>
        @withScene (scene) =>
            @_align scene
            @addDisposableListener scene.camera, 'move', => @_align scene

    outPort: (key) => @def ('out' + key)

    inPort: (key) => @def ('in' + key)

