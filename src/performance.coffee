require "babel-core/register"
require "babel-polyfill"
import * as basegl from 'basegl'

import {Breadcrumbs}     from 'view/Breadcrumbs'
import {Connection}      from 'view/Connection'
import {ExpressionNode}  from 'view/ExpressionNode'
import {InputNode}       from 'view/InputNode'
import {NodeEditor}      from 'view/NodeEditor'
import {OutputNode}      from 'view/OutputNode'
import {Searcher}        from 'view/Searcher'
import {subscribeEvents} from 'view/Component'

export install = (name, fontRootPath = "", f) ->
    scene = basegl.scene {domElement: name}
    basegl.fontManager.register 'DejaVuSansMono', fontRootPath + 'DejaVuSansMono.ttf'
    fontSettings =
        glyphSize: 20
        spread: 32
    basegl.fontManager.load('DejaVuSansMono', fontSettings).then =>
        nodeEditor = new NodeEditor scene
        nodeEditor.initialize()
        f nodeEditor

export onEvent = subscribeEvents

main = (f) -> install 'basegl-root', 'rsc/', f

window.run = main

rand = (to, from = 1) => Math.floor((Math.random() * (to + 1 - from)) + from)

generateInPorts = (count) =>
    ports = []
    unless count == 0
        for i in [1..count]
            ports.push
                key: i
    return ports

generateNode = (key) =>
    inPortsCount = rand(10, 0)

    new ExpressionNode
        key: key
        name: 'node' + key
        inPorts: generateInPorts rand 10
        outPorts: [{key: 1}]
        position: [rand(10000), rand(10000)]
        expanded: rand 1, 0
        selected: false

generateNodes = (count) =>
    nodes = []
    unless count == 0
        for i in [1..count]
            nodes.push generateNode i
    return nodes

generateConnection = (key, maxNode) =>
    new Connection
        key: key
        srcNode: rand maxNode
        srcPort: 1
        dstNode: rand maxNode
        dstPort: 1

generateConnections = (count, maxNode) =>
    connections = []
    unless count == 0
        for i in [1..count]
            connections.push generateConnection i, maxNode
    return connections

export runPerformance = (nodeEditor) ->
    nodeEditor.setBreadcrumbs new Breadcrumbs
        moduleName: 'Foo'
        items: ['bar', 'baz']

    nodesCount = 1000
    connectionsCount = 500

    nodeEditor.setNodes generateNodes nodesCount

    nodeEditor.setInputNode new InputNode
        key: 'in'
        outPorts: [ {key: 1}
                  , {key: 2}
                  , {key: 3}]

    nodeEditor.setOutputNode new OutputNode
        key: 'out'
        inPorts: [ {key: 1}
                 , {key: 2}]
    nodeEditor.setConnections generateConnections connectionsCount, nodesCount
    nodeEditor.setSearcher new Searcher
        key: 4
        mode: 'node'
        selected: 0
        entries: [
            name: 'bar'
            doc:  'bar description'
            className: 'Bar'
            highlights:
                [
                    start: 1
                    end: 2
                ]
        ,
            name: 'foo'
            doc:  'foo multiline\ndescription'
            className: 'Foo'
        ,
            name: 'baz'
            doc:  'baz description'
            className: 'Test'
            highlights:
                [
                    start: 1
                    end: 3
                ]
        ]


    subscribeEvents (path, event) =>
        console.warn {path: path, base: event}
    window.n = nodeEditor