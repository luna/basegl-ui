import {Navigator}          from 'basegl/navigation/Navigator'
import {ZoomlessCamera}     from 'basegl/navigation/Camera'

import {Breadcrumb}         from 'view/Breadcrumb'
import {Connection}         from 'view/Connection'
import {Disposable}         from 'abstract/Disposable'
import {ExpressionNode}     from 'view/ExpressionNode'
import {EventEmitter}       from 'abstract/EventEmitter'
import {HalfConnection}     from 'view/HalfConnection'
import {InputNode}          from 'view/InputNode'
import {OutputNode}         from 'view/OutputNode'
import {Searcher}           from 'view/Searcher'
import {NodeVisualizations} from 'view/Visualization'
import {visualizationCover} from 'view/Visualization'

import * as _ from 'underscore'


export class NodeEditor extends EventEmitter
    constructor: (@_scene) ->
        super()
        @nodes               ?= {}
        @connections         ?= {}
        @visualizations      ?= {}
        @visualizerLibraries ?= {}
        @inTransaction        = false
        @pending              = []
        @topDomScene          = @_scene.addDomModel('dom-top')
        @topDomSceneStill     = @_scene.addDomModelWithNewCamera('dom-top-still')
        @topDomSceneNoScale   =
            @_scene.addDomModelWithNewCamera('dom-top-no-scale', new ZoomlessCamera @_scene._camera)

        visCoverFamily = @_scene.register visualizationCover
        visCoverFamily.zIndex = -1

    withScene: (fun) =>
        action = => fun @_scene if @_scene?
        if @inTransaction
            @pending.push action
        else
            action()

    beginTransaction: => @inTransaction = true

    commitTransaction: =>
        @inTransaction = false
        for pending in @pending
            pending()
        @pending = []

    initialize: =>
        @withScene (scene) =>
            @controls = new Navigator scene
            @addDisposableListener scene, 'click',     @pushEvent
            @addDisposableListener scene, 'dblclick',  @pushEvent
            @addDisposableListener scene, 'mousedown', @pushEvent
            @addDisposableListener scene, 'mouseup',   @pushEvent

    getMousePosition: => @withScene (scene) =>
        campos = scene.camera.position
        x = (scene.screenMouse.x - scene.width/2) * campos.z + campos.x + scene.width/2
        y = (scene.height/2 - scene.screenMouse.y) * campos.z + campos.y + scene.height/2
        [x, y]

    node: (nodeKey) =>
        node = @nodes[nodeKey]
        if node? then node
        else if @inputNode?  and (@inputNode.model.key  is nodeKey) then @inputNode
        else if @outputNode? and (@outputNode.model.key is nodeKey) then @outputNode

    unsetNode: (node) =>
        if @nodes[node.key]?
            @nodes[node.key].dispose()
            delete @nodes[node.key]

    setNode: (node) =>
        if @nodes[node.key]?
            @nodes[node.key].set node
        else
            nodeView = new ExpressionNode node, @
            @nodes[node.key] = nodeView

    setNodes: (nodes) =>
        nodeKeys = new Set
        for node in nodes
            nodeKeys.add node.key
        for nodeKey in Object.keys @nodes
            unless nodeKeys.has nodeKey
                @unsetNode @nodes[nodeKey]
        for node in nodes
            @setNode node
        undefined

    setBreadcrumb: (breadcrumb) =>
        @genericSetComponent 'breadcrumb', Breadcrumb, breadcrumb
    setHalfConnections: (halfConnections) =>
        @genericSetComponents 'halfConnections', HalfConnection, halfConnections
    setInputNode: (inputNode) =>
        @genericSetComponent 'inputNode', InputNode, inputNode
    setOutputNode: (outputNode) =>
        @genericSetComponent 'outputNode', OutputNode, outputNode

    setVisualizerLibraries: (visLib) =>
        unless _.isEqual(@visualizerLibraries, visLib)
            @emitProperty 'visualizerLibraries', visLib

    setVisualization: (nodeVis) =>
        key = nodeVis.nodeKey
        if @visualizations[key]?
            @visualizations[key].set nodeVis
        else
            visView = new NodeVisualizations nodeVis, @
            @visualizations[key] = visView
        @node(key).onDispose =>
            if @visualizations[key]?
                @visualizations[key].dispose()
                delete @visualizations[key]

    unsetVisualization: (nodeVis) =>
        if @visualizations[nodeVis.nodeKey]?
            @visualizations[nodeVis.nodeKey].dispose()
            delete @visualizations[nodeVis.nodeKey]

    unsetConnection: (connection) =>
        if @connections[connection.key]?
            @connections[connection.key].dispose()
            delete @connections[connection.key]

    setConnection: (connection) =>
        if @connections[connection.key]?
            @connections[connection.key].set connection
        else
            connectionView = new Connection connection, @
            @connections[connection.key] = connectionView

    setConnections: (connections) =>
        connectionKeys = new Set
        for connection in connections
            connectionKeys.add connection.key
        for connectionKey in Object.keys @connections
            unless connectionKeys.has connectionKey
                @unsetConnection @connections[connectionKey]
        for connection in connections
            @setConnection connection
        undefined

    setDebugLayer: (layerNumber) =>
        if layerNumber? and layerNumber >= 0 and layerNumber <= 9
            @withScene (scene) =>
                scene._symbolRegistry.materials.uniforms.displayMode = layerNumber

    unsetDebugLayer: =>
        @withScene (scene) =>
            scene._symbolRegistry.materials.uniforms.displayMode = 0

    genericSetComponent: (name, constructor, value) =>
        if value?
            if @[name]?
                @[name].set value
            else
                @[name] = new constructor value, @
        else
            if @[name]?
                @[name].dispose()
                @[name] = null

    genericSetComponents: (name, constructor, values = []) =>
        @[name] ?= []
        if values.length != @[name].length
            for oldValue in @[name]
                oldValue.dispose()
            @[name] = []
            for value in values
                newValue = new constructor value, @
                @[name].push newValue
        else if values.length > 0
            for i in [0..values.length - 1]
                @[name][i].set values[i]

    destruct: =>
        @breadcrumb?.dispose()
        @inputNode?.dispose()
        @outputNode?.dispose()
        @searcher?.dispose()
        @visualizerLibraries?.dispose()
        @visualizations?.dispose()
        for connectionKey in Object.keys @connections
            @connections[connectionKey].dispose()
        for nodeKey in Object.keys @nodes
            @nodes[nodeKey].dispose()

    setSearcher: (searcherModel) =>
        unless searcherModel?
            @unregisterSearcher()
            return

        node = @node(searcherModel.key)
        unless node?
            @warn "No node to attatch the Searcher to."
            return

        node.setSearcher searcherModel

    unregisterSearcher: =>
        if @openSearcher?
            closingSearcher = @openSearcher
            @openSearcher = null
            closingSearcher.hideSearcher()

    registerSearcher: (searcher) =>
        if @openSearcher? and searcher.key != @openSearcher.key
            @openSearcher.hideSearcher()
        @openSearcher = searcher

    log: (msg) => console.log "[NodeEditor]", msg
