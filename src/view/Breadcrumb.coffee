import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape}          from 'shape/Html'
import * as style           from 'style'
import {BreadcrumbArrow}    from 'view/BreadcrumbArrow'
import {TextContainer}      from 'view/Text'
import {HorizontalLayout}   from 'widget/HorizontalLayout'


breadcrumbId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

breadcrumbHeight = 20
overlap = -1

export class Breadcrumb extends ContainerComponent
    initModel: =>
        position: [0,0]
        scale: 1
        moduleName: null
        items: []

    prepare: =>
        @addDef 'items', HorizontalLayout,
            height: breadcrumbHeight
            offset: overlap

    update: =>
        if @changed.once or @changed.items or @changed.moduleName
            breadcrumbArrow =
                cons: BreadcrumbArrow
                frameColor: [@style.breadcrumb_color_r, @style.breadcrumb_color_g, @style.breadcrumb_color_b]
                arrowColor: [@style.breadcrumb_arrowColor_r, @style.breadcrumb_arrowColor_g, @style.breadcrumb_arrowColor_b]

            breadcrumbItem = (item) =>
                cons: TextContainer
                align:      'left'
                border:     @style.breadcrumb_border
                color:      [@style.text_color_r, @style.text_color_g, @style.text_color_b]
                frameColor: [@style.breadcrumb_color_r, @style.breadcrumb_color_g, @style.breadcrumb_color_b]
                roundFrame: breadcrumbHeight/2
                size:       @style.text_size
                text:       item.name
                valign:     'top'
                onclick: if item.breadcrumb? then => @pushEvent
                    tag: 'NavigateEvent'
                    to: item.breadcrumb
            items = []
            if @model.items.length == 0
                items.push breadcrumbItem name: nullModuleNameError
            for item, i in @model.items
                if i == 0
                    if item.name == ''
                        items.push breadcrumbItem name: @model.moduleName
                    else
                        items.push breadcrumbItem item
                else
                    items.push breadcrumbArrow
                    items.push breadcrumbItem item
            @updateDef 'items', children: items

    adjust: (view) =>
        if @changed.position
            view.position.xy = @model.position.slice()
        if @changed.scale
            view.scale.xy = [@model.scale, @model.scale]

    __align: (scene) =>
        campos = scene.camera.position
        x = (campos.x + scene.width  / 2) / campos.z - scene.width/2 + @style.breadcrumb_offset
        y = (campos.y + scene.height / 2) / campos.z + scene.height/2 - @style.breadcrumb_offset
        @set
            position: [x, y]
            scale: campos.z

    connectSources: =>
        @withScene (scene) =>
            @__align scene
            # @addDisposableListener scene.camera, 'move', => @__align scene
