import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {world}        from 'basegl/display/World'
import {group}        from 'basegl/display/Symbol'
import {circle, glslShape, union, grow, negate, rect, quadraticCurve, path} from 'basegl/display/Shape'
import {Composable, fieldMixin} from "basegl/object/Property"

import {InPort, OutPort} from 'view/Port'
import {Component}       from 'view/Component'
import * as shape        from 'shape/Node'
import * as layers       from 'view/layers'
import * as util         from 'shape/util'
import * as _            from 'underscore'

visualizationTogglerButton         = basegl.symbol shape.togglerButtonShape
visualizationTogglerButton.bbox.xy = [shape.togglerSize, shape.togglerSize]
visualizationTogglerButton.variables.isFolded = 0

### Utils ###
selectedNode = null

applySelectAnimation = (symbol, rev=false) ->
    if symbol.selectionAnimation?
    then symbol.selectionAnimation.reverse()
    else
        anim = Animation.create
            easing      : Easing.quadInOut
            duration    : 0.1
            onUpdate    : (v) -> symbol.variables.selected = v
            onCompleted :     -> delete symbol.selectionAnimation
        if rev then anim.inverse()
        anim.start()
        symbol.selectionAnimation = anim
        anim

expandedNodeShape = basegl.symbol shape.expandedNodeShape
expandedNodeShape.defaultZIndex = layers.expandedNode
expandedNodeShape.variables.selected = 0
expandedNodeShape.variables.bodyWidth = 200
expandedNodeShape.variables.bodyHeight = 300

expandedNodeErrorShape = basegl.symbol shape.expandedNodeErrorShape
expandedNodeErrorShape.defaultZIndex = layers.expandedNodeError
expandedNodeErrorShape.variables.selected = 0
expandedNodeErrorShape.variables.bodyWidth = 200
expandedNodeErrorShape.variables.bodyHeight = 300

compactNodeShape = basegl.symbol shape.compactNodeShape
compactNodeShape.defaultZIndex = layers.compactNode
compactNodeShape.variables.selected = 0
compactNodeShape.bbox.xy = [shape.width, shape.height]

compactNodeErrorShape = basegl.symbol shape.compactNodeErrorShape
compactNodeErrorShape.defaultZIndex = layers.compactNodeError
compactNodeErrorShape.variables.selected = 0
compactNodeErrorShape.bbox.xy = [shape.errorWidth, shape.errorHeight]

nodeExprYOffset = shape.height / 3
nodeNameYOffset = nodeExprYOffset + 5
nodeValYOffset  = -nodeNameYOffset

portDistance = shape.height / 3

export class ExpressionNode extends Component
    updateModel: ({ key:        @key        = @key
                  , name:        name       = @name
                  , expression:  expression = @expression
                  , value:       value      = @value
                  , inPorts:     inPorts    = @inPorts
                  , outPorts:    outPorts   = @outPorts
                  , position:    position   = @position
                  , selected:    selected   = @selected
                  , expanded:    expanded   = @expanded
                  , hovered:    @hovered    = @hovered}) =>

        @emitProperty 'position', position
        if @expanded != expanded or @name != name or @expression != expression or not _.isEqual(@value, value)
            @name = name
            @expression = expression
            @value = value
            nameDef = util.text str: @name
            exprDef = util.text str: @expression
            nodeShape = if expanded then expandedNodeShape else compactNodeShape
            @def = [{ name: 'node', def: nodeShape }
                   ,{ name: 'name', def: nameDef }
                   ,{ name: 'expression', def: exprDef }
                   ]
            if @error()
                errorFrame = if expanded then expandedNodeErrorShape else compactNodeErrorShape
                @def.splice 0, 0, {name: 'errorFrame', def: errorFrame}
            if @shortValue()?
                value = util.text str: @shortValue()
                @def.splice 0, 0, {name: 'value', def: value}
            @def.splice 0, 0,
                name: 'valueToggler'
                def: visualizationTogglerButton
            @emitProperty 'expanded', expanded
            if @view?
                @reattach()
        if selected != @selected
            @selected = selected
            if @view?
                applySelectAnimation @view.node, not @selected
        @widgets ?= {}
        @setInPorts inPorts
        @setOutPorts outPorts
        @updateInPorts()
        @updateOutPorts()

    error: =>
        @value? and @value.tag == 'Error'

    shortValue: =>
        if @value? and @value.contents?
            @value.contents.contents

    setInPorts: (inPorts) =>
        @inPorts ?= {}
        if inPorts.length?
            for inPort in inPorts
                @setInPort inPort
        else
            for own k, inPort of inPorts
                @setInPort inPort

    setInPort: (inPort) =>
        if @inPorts[inPort.key]?
            @inPorts[inPort.key].set inPort
        else
            portView = new InPort inPort, @
            @inPorts[inPort.key] = portView
            portView.attach()
            @onDispose => portView.dispose()

    setOutPorts: (outPorts) =>
        @outPorts ?= {}
        if outPorts.length?
            for outPort in outPorts
                @setOutPort outPort
        else
            for own k, outPort of outPorts
                @setOutPort outPort

    setOutPort: (outPort) =>
        if @outPorts[outPort.key]?
            @outPorts[outPort.key].set outPort
        else
            portView = new OutPort outPort, @
            @outPorts[outPort.key] = portView
            portView.attach()
            @onDispose => portView.dispose()

    drawWidgets: (widgets, startPoint, width) =>
        return unless widgets.length > 0
        ws = []
        minWidth = 0
        for i in [0..widgets.length - 1]
            ws.push
                index  : i
                widget : widgets[i]
                width : widgets[i].minWidth
            minWidth += widgets[i].minWidth
            widgets[i].configure siblings:
                left:  ! (i == 0)
                right: ! (i == widgets.length - 1)
        offset = 3
        free = width - minWidth - offset * (widgets.length - 1)
        ws.sort (a, b) -> a.widget.maxWidth - b.widget.maxWidth
        for i in [0..ws.length - 1]
            w = ws[i]
            wfree = free / (ws.length - i)
            if (! w.widget.maxWidth?) or w.widget.maxWidth > w.width + wfree
                free -= wfree
                w.width += wfree
            else
                free -= w.widget.maxWidth - w.width
                w.width = w.widget.maxWidth
        ws.forEach (w) ->
            widgets[w.index].set position: startPoint.slice()
            widgets[w.index].configure width: w.width
            startPoint[0] += w.width + offset

    updateValueView: =>
        valueSize     = [0,0]
        valuePosition = @view.node.position
        if @view.value?
            valueSize = util.textSize @view.value
            @view.value.position.y = @view.node.position.y - valueSize[1]/2
            unless @expanded
                @view.value.position.x = -valueSize[0]/2
            valuePosition = @view.value.position

        @view.valueToggler.position.x = -shape.togglerSize/2
        @view.valueToggler.position.y =
            @view.node.position.y - valueSize[1] - shape.togglerSize/2
        if @value?.contents?.tag == 'Visualization'
            @view.valueToggler.variables.isFolded = 0.0
        else
            @view.valueToggler.variables.isFolded = 1.0
        
    updateView: =>
        if @expanded
            @view.node.variables.bodyHeight = @bodyHeight
            @view.node.variables.bodyWidth  = @bodyWidth
            nodePosition = [-shape.width/2, -@bodyHeight - shape.height/2 - shape.slope]
            @view.node.position.xy = nodePosition
            if @error()
                @view.errorFrame.variables.bodyHeight = @bodyHeight
                @view.errorFrame.variables.bodyWidth  = @bodyWidth
                @view.errorFrame.position.xy = nodePosition
            for own inPortKey, inPort of @inPorts
                widgets = @widgets[inPortKey]
                if widgets?
                    leftOffset = 50
                    startPoint = [inPort.position[0] + leftOffset, inPort.position[1]]
                    width = @bodyWidth - 20
                    @drawWidgets widgets, startPoint, width
        else
            @view.node.position.xy = [-shape.width/2, -shape.height/2]
            if @error()
                @view.errorFrame.position.xy = [-shape.width/2, -shape.height/2]
        @updateValueView()
        nameSize = util.textSize @view.name
        exprWidth = util.textWidth @view.expression
        @view.name.position.xy = [-nameSize[0]/2, nodeNameYOffset + nameSize[1]]
        @view.expression.position.xy = [-exprWidth/2, nodeExprYOffset]
        @group.position.xy = @position.slice()
        @view.node.variables.selected = if @selected then 1 else 0

    updateInPorts: =>
        @selfPort = undefined
        inPortNumber = 0
        inPortKeys = Object.keys @inPorts
        for inPortKey in inPortKeys
            inPort = @inPorts[inPortKey]
            values = {}
            values.locked = @expanded
            if inPort.mode == 'self'
                @selfPort = inPort
                values.radius = 0
                values.angle = Math.PI/2
                values.position = @position.slice()
            else if @expanded
                values.radius = 0
                values.angle = Math.PI/2
                values.position =
                    [ @position[0] - shape.height/2
                    , @position[1] - shape.height/2 - inPortNumber * 50
                    ]
                inPortNumber++
            else
                values.radius = portDistance
                if inPortKeys.length == 1
                    values.angle = Math.PI/2
                else
                    values.angle = Math.PI * (0.25 + 0.5 * inPortNumber/(inPortKeys.length-1))
                values.position = @position.slice()
                inPortNumber++

            if @expanded
                unless @widgets[inPortKey]?
                    @widgets[inPortKey] = []
                    inPort.widgets.forEach (widgetCreate) =>
                        widget = widgetCreate @parent
                        widget.attach()
                        @onDispose => widget.dispose()
                        @widgets[inPortKey].push widget
            else
                if @widgets[inPortKey]?
                    @widgets[inPortKey].forEach (widget) =>
                        widget.detach()
                    delete @widgets[inPortKey]
            inPort.set values
        # Those values should be calculated based on informations about port widgets
        @bodyWidth = 200
        @bodyHeight = 300

    updateOutPorts: =>
        outPortNumber = 0
        outPortKeys = Object.keys @outPorts
        for outPortKey in outPortKeys
            outPort = @outPorts[outPortKey]
            values = {}
            unless outPort.angle?
                if outPortKeys.length == 1
                    values.angle = Math.PI*3/2
                else
                    values.angle = Math.PI * (1.25 + 0.5 * outPortNumber/(outPortKeys.length-1))
                values.radius = portDistance
            values.position = @position.slice()
            outPort.set values
            outPortNumber++

    registerEvents: =>
        @group.addEventListener 'dblclick',  @pushEvent
        @view.valueToggler?.addEventListener 'mouseup', => @pushEvent
            tag: 'ToggleVisualizationsEvent'
        @makeHoverable()
        @makeDraggable()
        @makeSelectable()

    makeHoverable: =>
        @group.addEventListener 'mouseenter', => @set hovered: true
        @group.addEventListener 'mouseleave', => @set hovered: false

    makeSelectable: =>
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

            @group.addEventListener 'mousedown', (e) =>
                if e.button != 0 then return
                if selectedNode == @
                    return
                else if selectedNode?
                    performSelect false
                performSelect true
                scene.addEventListener 'mousedown', unselect

    makeDraggable: =>
        dragHandler = (e) =>
            if e.button != 0 then return
            moveNodes = (e) =>
                @withScene (scene) =>
                    x = @position[0] + e.movementX * scene.camera.zoomFactor
                    y = @position[1] - e.movementY * scene.camera.zoomFactor
                    @set position: [x, y]

            dragFinish = =>
                @pushEvent
                    tag: 'NodeMoveEvent'
                    position: @position
                window.removeEventListener 'mouseup', dragFinish
                window.removeEventListener 'mousemove', moveNodes
            window.addEventListener 'mouseup', dragFinish
            window.addEventListener 'mousemove', moveNodes
        @group.addEventListener 'mousedown', dragHandler
        @selfPort?.subport?.group.addEventListener 'mousedown', dragHandler
