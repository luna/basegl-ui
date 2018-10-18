import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape}          from 'shape/Html'
import * as style           from 'style'
import {HorizontalLayout}   from 'widget/HorizontalLayout'
import {TextContainer}      from 'view/Text'

breadcrumbId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

breadcrumbHeight = 20

export class Breadcrumb extends ContainerComponent
    initModel: =>
        position: [0,0]
        scale: 1
        moduleName: null
        items: []

    prepare: =>
        @addDef 'items', HorizontalLayout,
            height: breadcrumbHeight
            offset: -1

    update: =>
        if @changed.once or @changed.items or @changed.moduleName
            breadcrumbItem = (item) =>
                cons: TextContainer
                align:      'left'
                border:     10
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
                items.push breadcrumbItem if i == 0 and item == ''
                                              name: @model.moduleName
                                          else
                                              item
            @updateDef 'items', children: items

    adjust: (view) =>
        if @changed.position
            view.position.xy = @model.position.slice()
        if @changed.scale
            view.scale.xy = [@model.scale, @model.scale]

    __align: (scene) =>
        campos = scene.camera.position
        x = (campos.x + scene.width  / 2) / campos.z - scene.width/2
        y = (campos.y + scene.height / 2) / campos.z + scene.height/2
        @set
            position: [x, y]
            scale: campos.z

    connectSources: =>
        @withScene (scene) =>
            @__align scene
            @addDisposableListener scene.camera, 'move', => @__align scene
