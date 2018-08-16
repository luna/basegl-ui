import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {group}        from 'basegl/display/Symbol'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"
import * as _         from 'underscore'

import {BasicComponent}         from 'abstract/BasicComponent'
import {Component}              from 'abstract/Component'
import {ContainerComponent}     from 'abstract/ContainerComponent'
import * as shape               from 'shape/node/Base'
import {NodeShape}              from 'shape/node/Node'
import {NodeErrorShape}         from 'shape/node/ErrorFrame'
import * as togglerShape        from 'shape/visualization/ValueToggler'
import {EditableText}           from 'view/EditableText'
import {InPort}                 from 'view/port/In'
import {OutPort}                from 'view/port/Out'
import {TextContainer}          from 'view/Text'
import {VisualizationContainer} from 'view/visualization/Container'
import {HorizontalLayout}       from 'widget/HorizontalLayout'

### Utils ###
selectedNode = null


exprOffset = 25
nodeExprYOffset = shape.height / 3
nodeNameYOffset = nodeExprYOffset + exprOffset
nodeValYOffset  = -nodeNameYOffset

portDistance = shape.height / 3
widgetOffset = 20
widgetHeight = 20
inportVDistance = widgetOffset + widgetHeight
minimalBodyHeight = 60

testEntries = [
    { name: 'bar', doc: 'bar description', className: 'Bar', highlights: [ { start: 1, end: 2 } ] },
    { name: 'foo', doc: 'foo multiline\ndescription', className: 'Foo', highlights: [] },
    { name: 'baz', doc:  'baz description', className: 'Test', highlights: [ { start: 1, end: 3 } ] }
]

export class ExpressionNode extends ContainerComponent
    initModel: =>
        key:        null
        name:       ''
        expression: ''
        value:      null
        inPorts:    {}
        outPorts:   {}
        position:   [0, 0]
        selected:   false
        expanded:   false
        hovered:    false
        visualizations: null

    prepare: =>
        @addDef 'node', NodeShape, expanded: @model.expanded
        @addDef 'name', EditableText,
            text:     @model.name
            entries:  []
            kind:     EditableText.NAME
        @addDef 'expression', EditableText,
            text:    @model.expression
            entries: []
            kind:    EditableText.EXPRESSION
        @addDef 'visualization', VisualizationContainer, null

    update: =>
        @updateDef 'name', text: @model.name
        @updateDef 'expression', text: @model.expression

        if @changed.inPorts or @changed.expanded
            setInPort  = (k, inPort)  =>
                @autoUpdateDef ('in'  + k),  InPort, inPort

            for own k, inPort of @model.inPorts
                setInPort k, inPort
            @updateInPorts()
        if @model.expanded
            setWidget = (k) =>
                @autoUpdateDef ('widget' + k), HorizontalLayout,
                    key: k
                    children: inPort.controls
                    width: @bodyWidth - widgetOffset
                    height: widgetHeight
            for own k, inPort of @model.inPorts
                setWidget k, inPort

        if @changed.outPorts
            setOutPort = (k, outPort) => @autoUpdateDef ('out' + k), OutPort, outPort
            for own k, outPort of @model.outPorts
                setOutPort k, outPort
            @updateOutPorts()

        @updateDef 'node',
            expanded: @model.expanded
            selected: @model.selected
            body: [@bodyWidth, @bodyHeight]

        if @changed.value or @changed.expanded
            @autoUpdateDef 'errorFrame', NodeErrorShape, if @error()
                expanded: @model.expanded
                body: [@bodyWidth, @bodyHeight]

        @updateDef 'visualization',
            value: @model.value
            visualizers: @model.visualizations?.visualizers
            visualizations: @model.visualizations?.visualizations

    outPort: (key) => @def ('out' + key)
    inPort: (key) => @def ('in' + key)

    error: =>
        @model.value? and @model.value.tag == 'Error'

    setSearcher: (searcherModel) =>
        @def(searcherModel.targetField)?.setSearcher searcherModel

    adjust: (view) =>
        if @model.expanded
            for own inPortKey, inPortModel of @model.inPorts
                inPort = @def('in' + inPortKey)
                if inPortModel.controls?
                    leftOffset = 50
                    startPoint = [inPort.model.position[0] + leftOffset, inPort.model.position[1]]
                    @view('widget' + inPortKey).position.xy = startPoint
        @view('visualization').position.xy =
            if @model.expanded
                [ - shape.width/2
                , - @bodyHeight - shape.height/2 - shape.slope - togglerShape.size ]
            else
                [ - shape.width/2, - shape.height/2 - togglerShape.size]
        @view('name').position.y = nodeNameYOffset
        @view('expression').position.y = nodeExprYOffset
        view.position.xy = @model.position.slice()

    updateInPorts: =>
        @bodyWidth = 200
        inPortNumber = 0
        nonSelfPortNumber = 0
        inPortKeys = Object.keys @model.inPorts
        for inPortKey, inPort of @model.inPorts
            values = {}
            values.locked = @model.expanded
            if inPort.mode == 'self'
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [0, 0]
            else if @model.expanded
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [- shape.height/2
                                  ,- shape.height/2 - inPortNumber * inportVDistance]
                inPortNumber++
                nonSelfPortNumber++
            else
                values.position = [0,0]
                values.radius = portDistance
                if inPortKeys.length == 1
                    values.angle = Math.PI/2
                else
                    values.angle = Math.PI * (0.25 + 0.5 * inPortNumber/(inPortKeys.length-1))
                inPortNumber++
            @def('in' + inPortKey).set values
        @bodyHeight = minimalBodyHeight + inportVDistance * if nonSelfPortNumber > 0 then nonSelfPortNumber - 1 else 0


    updateOutPorts: =>
        outPortNumber = 0
        outPortKeys = Object.keys @model.outPorts
        for own outPortKey, outPort of @model.outPorts
            values = {}
            unless outPort.angle?
                if outPortKeys.length == 1
                    values.angle = Math.PI*3/2
                else
                    values.angle = Math.PI * (1.25 + 0.5 * outPortNumber/(outPortKeys.length-1))
                values.radius = portDistance
            @def('out' + outPortKey).set values
            outPortNumber++

    registerEvents: (view) =>
        view.addEventListener 'dblclick', (e) => @pushEvent e
        @makeHoverable view
        @makeDraggable view
        @makeSelectable view

    makeHoverable: (view) =>
        view.addEventListener 'mouseenter', => @set hovered: true
        view.addEventListener 'mouseleave', => @set hovered: false

    makeSelectable: (view) =>
        @withScene (scene) =>
            performSelect = (select) =>
                target = selectedNode or @
                target.pushEvent
                    tag: 'NodeSelectEvent'
                    select: select
                target.set selected: select
                selectedNode = if select then @ else null

            unselect = (e) =>
                scene.removeEventListener 'mousedown', unselect
                performSelect false

            view.addEventListener 'mousedown', (e) =>
                if e.button != 0 then return
                if selectedNode == @
                    return
                else if selectedNode?
                    performSelect false
                performSelect true
                scene.addEventListener 'mousedown', unselect

    makeDraggable: (view) =>
        dragHandler = (e) =>
            if e.button != 0 then return
            moveNodes = (e) =>
                @withScene (scene) =>
                    x = @model.position[0] + e.movementX * scene.camera.zoomFactor
                    y = @model.position[1] - e.movementY * scene.camera.zoomFactor
                    @set position: [x, y]

            dragFinish = =>
                @pushEvent
                    tag: 'NodeMoveEvent'
                    position: @model.position
                window.removeEventListener 'mouseup', dragFinish
                window.removeEventListener 'mousemove', moveNodes
            window.addEventListener 'mouseup', dragFinish
            window.addEventListener 'mousemove', moveNodes
        view.addEventListener 'mousedown', dragHandler
