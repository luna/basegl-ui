import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {group}        from 'basegl/display/Symbol'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import * as shape           from 'shape/node/Base'
import * as togglerShape    from 'shape/node/ValueToggler'
import * as _               from 'underscore'
import {BasicComponent}     from 'abstract/BasicComponent'
import {Component}          from 'abstract/Component'
import {ContainerComponent} from 'abstract/ContainerComponent'
import {NodeShape}          from 'shape/node/Node'
import {NodeErrorShape}     from 'shape/node/ErrorFrame'
import {ValueTogglerShape}  from 'shape/node/ValueToggler'
import {EditableText}       from 'view/EditableText'
import {InPort}             from 'view/port/In'
import {NewPort}            from 'view/port/New'
import {OutPort}            from 'view/port/Out'
import {TextContainer}      from 'view/Text'
import {SetView}            from 'view/SetView'
import {HorizontalLayout}   from 'widget/HorizontalLayout'

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
        newPortKey: null
        position:   [0, 0]
        selected:   false
        expanded:   false
        hovered:    false

    prepare: =>
        @addDef 'node', new NodeShape expanded: @model.expanded, @
        @addDef 'name', new EditableText
                text:     @model.name
                entries:  []
                kind:     EditableText.NAME
            , @
        @addDef 'expression', new EditableText
                text:    @model.expression
                entries: []
                kind:    EditableText.EXPRESSION
            , @
        @addDef 'valueToggler', new ValueTogglerShape null, @
        @addDef 'inPorts',  new SetView cons: InPort, @
        @addDef 'outPorts', new SetView cons: OutPort, @
        @addDef 'newPort', new NewPort null, @

    update: =>
        @updateDef 'name', text: @model.name
        @updateDef 'expression', text: @model.expression
        @updateDef 'newPort', key: @model.newPortKey
        if @changed.inPorts or @changed.expanded
            @updateDef 'inPorts', elems: @model.inPorts
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
            @updateDef 'outPorts', elems: @model.outPorts
            @updateOutPorts()

        @updateDef 'node',
            expanded: @model.expanded
            selected: @model.selected
            body: [@bodyWidth, @bodyHeight]

        if @changed.value or @changed.expanded
            @autoUpdateDef 'errorFrame', NodeErrorShape, if @error()
                expanded: @model.expanded
                body: [@bodyWidth, @bodyHeight]
        if @changed.value
            @autoUpdateDef 'value', TextContainer, if @__shortValue()?
                align: 'center'
                text: @__shortValue()
                body: [@bodyWidth, @bodyHeight]

        @updateDef 'valueToggler',
            isFolded: @model.value?.contents?.tag != 'Visualization'
            expanded: @model.expanded
            body: [@bodyWidth, @bodyHeight]

    outPort: (key) => @def('outPorts').def(key)
    inPort: (key) => @def('inPorts').def(key) or if key == @model.newPortKey then @def('newPort')

    error: =>
        @model.value? and @model.value.tag == 'Error'

    __shortValue: =>
        if @model.value? and @model.value.contents?
            @model.value.contents.contents

    setSearcher: (searcherModel) =>
        @def(searcherModel.targetField)?.setSearcher searcherModel

    adjust: (view) =>
        if @model.expanded
            for own inPortKey, inPortModel of @model.inPorts
                inPort = @def('inPorts').def(inPortKey)
                if inPortModel.controls?
                    leftOffset = 50
                    startPoint = [inPort.model.position[0] + leftOffset, inPort.model.position[1]]
                    @view('widget' + inPortKey).position.xy = startPoint

        if @__shortValue()?
            @view('value').position.xy =
                if @model.expanded
                    [ shape.width/2
                    , - @bodyHeight - shape.height/2 - shape.slope - togglerShape.size ]
                else
                    [ 0, - shape.height/2 - togglerShape.size]
        @view('name').position.y = nodeNameYOffset
        @view('expression').position.y = nodeExprYOffset
        view.position.xy = @model.position.slice()

    updateInPorts: =>
        @bodyWidth = 200
        inPortNumber = 1
        inPortsCount = 0
        for k, inPort of @model.inPorts
            unless inPort.mode == 'self'
                inPortsCount++

        portProperties = (port) =>
            values = {}
            values.locked = @model.expanded
            if port.mode == 'self'
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [0, 0]
            else if @model.expanded
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [- shape.height/2
                                  ,- shape.height/2 - (inPortNumber - 1) * inportVDistance]
                inPortNumber++
            else
                values.position = [0,0]
                values.radius = portDistance
                values.angle = Math.PI * (inPortNumber/(inPortsCount+1))
                inPortNumber++
            values

        for inPortKey, inPort of @model.inPorts
            @def('inPorts').def(inPortKey).set portProperties inPort
        @def('newPort').set portProperties mode:'phantom'
        @bodyHeight = minimalBodyHeight + inportVDistance * if inPortsCount > 0 then inPortsCount - 1 else 0


    updateOutPorts: =>
        outPortNumber = 1
        outPortsNumber = Object.keys(@model.outPorts).length
        for own outPortKey, outPort of @model.outPorts
            values = {}
            unless outPort.angle?
                values.angle = Math.PI * (1 + outPortNumber/(outPortsNumber + 1))
                values.radius = portDistance
            @def('outPorts').def(outPortKey).set values
            outPortNumber++

    registerEvents: (view) =>
        view.addEventListener 'dblclick', (e) => @pushEvent e
        @view('valueToggler').addEventListener 'mouseup', (e) => @pushEvent e,
            tag: 'ToggleVisualizationsEvent'
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
