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

    align: (x, y) =>
        unless x == @model.position[0] and y == @model.position[1]
            @set position: [x, y]

    connectSources: =>
        @withScene (scene) =>
            @addDisposableListener scene.camera, 'move', =>
                campos = scene.camera.position
                x = scene.width/2 + campos.x + scene.width/2*campos.z
                y = scene.height/2 + campos.y - height/2
                @align x, y

    outPort: (key) => @def ('out' + key)

    inPort: (key) => @def ('in' + key)

# height = 100

# export class InputNode extends ContainerComponent
#     initModel: =>
#         key: null
#         outPorts: {}
#         position: [0, 0]
    
#     prepare: =>
#         @addDef 'add', new AddPortShape null, @
    
#     update: =>
#         i = 0
#         keys = Object.keys @model.outPorts
#         portOffset = height / keys.length
#         newPosition = =>
#             pos = [ 0 , 0 + portOffset * keys.length - i * portOffset]
#             i++
#             return pos
#         for own k, outPort of @model.outPorts
#             outPort.position = newPosition()
#             @autoUpdateDef ('out' + k), FlatPort, outPort
#         @addPortPosition = newPosition()

#     adjust: (view) =>
#         @view('add').position.xy = [ @addPortPosition[0]
#                                    , @addPortPosition[1]
#                                    ]
#         view.position.xy = @model.position.slice()
        
#     align: (x, y) =>
#         unless x == @model.position[0] and y == @model.position[1]
#             @set position: [x, y]

#     connectSources: =>
#         @withScene (scene) =>
#             @addDisposableListener scene.camera, 'move', =>
#                 campos = scene.camera.position
#                 x = scene.width/2 + campos.x - scene.width/2*campos.z
#                 y = scene.height/2 + campos.y - height/2
#                 @align x, y

