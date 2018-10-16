require "babel-core/register"
require "babel-polyfill"
import * as basegl from 'basegl'

import {NodeEditor}      from 'view/NodeEditor'
import {subscribeEvents} from 'abstract/EventEmitter'


export install = (name, fontRootPath = "", f) ->
    scene = basegl.scene {domElement: name}
    basegl.fontManager.register 'SourceCodePro', fontRootPath + 'SourceCodeVariable-Roman.ttf'
    fontSettings =
        glyphSize: 20
        spread: 32
    basegl.fontManager.load('SourceCodePro', fontSettings).then =>
        nodeEditor = new NodeEditor scene
        nodeEditor.initialize()
        f nodeEditor

export onEvent = subscribeEvents

main = (f) -> install 'node-editor-mount', 'rsc/', f

window.run = main

rand = (to, from = 1) => Math.floor((Math.random() * (to + 1 - from)) + from)

generateInPorts = (count) =>
    ports = {}
    unless count == 0
        for i in [1..count]
            ports[i] = {}
    return ports

generateNode = (key) =>
    key: key
    name: 'node' + key
    inPorts: generateInPorts rand 10
    outPorts:
        1: {}
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
    nodeEditor.setBreadcrumb
        moduleName: 'Foo'
        items:
            [
                name: 'bar'
                breadcrumb: 1
            ,
                name: 'baz'
                breadcrumb: 2
            ]

    nodesCount = 1000
    connectionsCount = 500

    nodeEditor.setNodes generateNodes nodesCount

    nodeEditor.setInputNode
        key: 'in'
        outPorts:
            1: {}
            2: {}
            3: {}

    nodeEditor.setOutputNode
        key: 'out'
        inPorts:
            1: {}
            2: {}
    nodeEditor.setConnections generateConnections connectionsCount, nodesCount
    nodeEditor.setSearcher
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
