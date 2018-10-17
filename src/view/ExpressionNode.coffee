import * as Easing    from 'basegl/animation/Easing'
import * as _         from 'underscore'

import {ContainerComponent} from 'abstract/ContainerComponent'
import * as shape           from 'shape/node/Base'
import {NodeShape}          from 'shape/node/Node'
import {NodeErrorShape}     from 'shape/node/ErrorFrame'
import * as togglerShape    from 'shape/visualization/ValueToggler'
import {EditableText}       from 'view/EditableText'
import {InPort}             from 'view/port/In'
import {NewPort}            from 'view/port/New'
import {OutPort}            from 'view/port/Out'
import {SetView}            from 'view/SetView'
import {NodeBody}           from 'view/NodeBody'
import {IconLoader}         from 'view/IconLoader'
import {HorizontalLayout}   from 'widget/HorizontalLayout'
import {VerticalLayout}     from 'widget/VerticalLayout'
import * as portBase        from 'shape/port/Base'

selectedNode = null


exprOffset = 25
nodeExprYOffset = (style) -> shape.height(style) / 3
nodeNameYOffset = (style) -> nodeExprYOffset(style) + exprOffset

minimalBodyHeight = (style) -> 2 * style.node_widgetOffset_v + style.node_widgetHeight
bodyTop = (style) -> - style.node_radius - style.node_widgetHeight/2 -
    style.node_headerOffset - style.node_widgetOffset_v
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
        icon:       null
        inPorts:    {}
        outPorts:   {}
        newPortKey: null
        position:   [0, 0]
        selected:   false
        expanded:   false
        hovered:    false
        visualizations: null

    prepare: =>
        @addDef 'node', NodeShape
        @addDef 'name', EditableText,
            entries:  []
            kind:     EditableText.NAME
            color:    [@style.text_color_r, @style.text_color_g, @style.text_color_b]
            frameColor:
                [ @style.port_borderColor_h, @style.port_borderColor_s
                , @style.port_borderColor_l, @style.port_borderColor_a
                ]
        @addDef 'expression', EditableText,
            entries: []
            kind:    EditableText.EXPRESSION
        @addDef 'body', NodeBody
        @addDef 'inPorts',  SetView, cons: InPort
        @addDef 'outPorts', SetView, cons: OutPort
        @addDef 'newPort', NewPort
        @addDef 'icon', IconLoader

    update: =>
        @updateDef 'icon', icon: @model.icon
        @updateDef 'name',
            text:     @model.name
            color:    [@style.text_color_r, @style.text_color_g, @style.text_color_b, @model.hovered]
            frameColor:
                [ @style.port_borderColor_h, @style.port_borderColor_s
                , @style.port_borderColor_l, @style.port_borderColor_a * Number @model.hovered
                ]
        @updateDef 'expression',
            text:    @model.expression
            color:    [@style.text_color_r, @style.text_color_g, @style.text_color_b]
            frameColor:
                [ @style.port_borderColor_h, @style.port_borderColor_s
                , @style.port_borderColor_l, @style.port_borderColor_a
                ]

        @updateDef 'newPort', key: @model.newPortKey
        if @changed.inPorts or @changed.expanded
            @updateInPorts()
        if @changed.outPorts
            @updateDef 'outPorts', elems: @model.outPorts
            @updateOutPorts()

        @updateDef 'node', selected: @model.selected

        if @changed.value
            @autoUpdateDef 'errorFrame', NodeErrorShape, if @error() then {}

        @updateDef 'body',
            inPorts: @model.inPorts
            expanded: @model.expanded
            value: @model.value
            visualizers: @model.visualizations?.visualizers
            visualizations: @model.visualizations?.visualizations

    outPort: (key) => @def('outPorts').def(key)
    inPort: (key) => @def('inPorts').def(key) or if key == @model.newPortKey then @def('newPort')

    error: =>
        @model.value? and @model.value.tag == 'Error'

    setSearcher: (searcherModel) =>
        @def(searcherModel.targetField)?.setSearcher searcherModel

    adjust: (view) =>
        if @changed.once
            @view('body').position.xy = [-@style.node_bodyWidth/2, -@style.node_radius - @style.node_headerOffset]
            @view('name').position.y = nodeNameYOffset @style
            @view('expression').position.y = nodeExprYOffset @style
        view.position.xy = @model.position.slice()

    updateInPorts: =>
        @updateDef 'inPorts', elems: @model.inPorts
        inportVDistance = @style.node_widgetOffset_v + @style.node_widgetHeight
        inPortNumber = 1
        inPortsCount = 0
        for k, inPort of @model.inPorts
            unless inPort.mode == 'self'
                inPortsCount++

        portProperties = (port) =>
            values = {}
            values.expanded = @model.expanded
            if port.mode == 'self'
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [0, 0]
            else if @model.expanded
                values.radius = 0
                values.angle = Math.PI/2
                values.position = [ - @style.node_bodyWidth/2 - portBase.distanceFromCenter(@style) + @style.node_radius
                                  , bodyTop(@style) - (inPortNumber - 1) * inportVDistance]
                inPortNumber++
            else
                values.position = [0,0]
                values.radius = portBase.distanceFromCenter @style
                values.angle = Math.PI * (inPortNumber/(inPortsCount+1))
                inPortNumber++
            values

        for inPortKey, inPort of @model.inPorts
            @def('inPorts').def(inPortKey).set portProperties inPort
        @def('newPort').set portProperties mode:'phantom'
        @bodyHeight = minimalBodyHeight(@style) + inportVDistance * if inPortsCount > 0 then inPortsCount - 1 else 0


    updateOutPorts: =>
        outPortNumber = 1
        outPortsNumber = Object.keys(@model.outPorts).length
        for own outPortKey, outPort of @model.outPorts
            values = {}
            unless outPort.angle?
                values.angle = Math.PI * (1 + outPortNumber/(outPortsNumber + 1))
                values.radius = portBase.distanceFromCenter @style
            @def('outPorts').def(outPortKey).set values
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
