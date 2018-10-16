import {Background}       from 'shape/node/Background'
import {Widget}           from 'widget/Widget'
import {VerticalLayout}   from 'widget/VerticalLayout'
import {HorizontalLayout} from 'widget/HorizontalLayout'

export class Parameters extends Widget
    initModel: =>
        model = super()
        model.inPorts = {}
        model

    update: =>
        if @changed.inPorts
            @autoUpdateDef 'widgets', VerticalLayout,
                width: @style.node_bodyWidth - 2*@style.node_widgetOffset_h
                offset: @style.node_widgetOffset_v
                children: for own key, inPort of @model.inPorts
                    key: key
                    cons: HorizontalLayout
                    children: inPort.controls
                    offset: @style.node_widgetSeparation
            @__minHeight = @def('widgets').height() + @style.node_widgetOffset_v

            @autoUpdateDef 'background', Background,
                height: @__minHeight
                width: @style.node_bodyWidth
        if @changed.siblings
            @updateDef 'background',
                roundBottom: not @model.siblings.bottom
                roundTop:    not @model.siblings.top

    adjust: =>
        if @changed.once
            @view('widgets').position.xy = [@style.node_widgetOffset_h, - @style.node_widgetHeight/2]
