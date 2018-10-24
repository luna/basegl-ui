import {Background}       from 'shape/node/Background'
import {Widget}           from 'widget/Widget'
import {VerticalLayout}   from 'widget/VerticalLayout'
import {HorizontalLayout} from 'widget/HorizontalLayout'
import {Placeholder}      from 'widget/Placeholder'

mkControls = (style, name, portControls) =>
    x = if portControls?.length
        portControls
    else
        [
            cons: Placeholder
            constHeight: style.node_widgetHeight
        ]
    x

export class Parameters extends Widget
    initModel: =>
        model = super()
        model.inPorts = {}
        model.controls = {}
        model.newPortKey = null
        model

    update: =>
        if @changed.inPorts or @changed.controls or @changed.newPortKey
            children = for own key, inPort of @model.inPorts
                key: key
                cons: HorizontalLayout
                children: mkControls(@style, key, @model.controls[key]?.controls)
                height: @style.node_widgetHeight
                offset: @style.node_widgetSeparation
            for own key, controls of @model.controls
                unless @model.inPorts[key]?
                    children.push
                        key: key
                        cons: HorizontalLayout
                        children: controls.controls
                        offset: @style.node_widgetSeparation
            if @model.newPortKey?
                children.push
                    key: @model.newPortKey
                    cons: Placeholder
                    constHeight: 0
            @autoUpdateDef 'widgets', VerticalLayout,
                width: @style.node_bodyWidth - 2*@style.node_widgetOffset_h
                offset: @style.node_widgetOffset_v
                children: children
            @__minHeight = @def('widgets').height() + 2*@style.node_widgetOffset_v

            @autoUpdateDef 'background', Background,
                height: @__minHeight
                width: @style.node_bodyWidth
        if @changed.siblings
            @updateDef 'background',
                roundBottom: not @model.siblings.bottom
                roundTop:    not @model.siblings.top
    adjustSrc: (view) =>
        view.position.xy = [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
        @view('widgets').scale.xy = [0,0]
        @view('background').scale.xy = [0,0]
        @setPosition view, [@style.node_widgetOffset_h, 0]
        @setPosition view, [0, 100]
    adjustDst: (view) =>
        @setPosition view, [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
        @setScale @view('widgets'), [0,0]
        @setScale @view('background'), [0, 0]

    adjust: (view) =>
        if @changed.once
            @setPosition view, [0, 0]
            @setScale @view('widgets'), [1, 1]
            @setScale @view('background'), [1, 1]
            @view('widgets').position.xy =
                [@style.node_widgetOffset_h, - @style.node_widgetOffset_v - @style.node_widgetHeight/2]
