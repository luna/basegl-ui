import {ContainerComponent} from 'abstract/ContainerComponent'
import {HtmlShape}          from 'shape/Html'
import * as style           from 'style'
import {HorizontalLayout}   from 'widget/HorizontalLayout'
import {TextContainer}      from 'view/Text'

breadcrumbId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

breadcrumbHeigth = 20

export class Breadcrumb extends ContainerComponent
    initModel: =>
        moduleName: null
        items: []

    prepare: =>
        @addDef 'items', HorizontalLayout,
            height: breadcrumbHeigth
            offset: 0

    update: =>
        if @changed.once or @changed.items or @changed.moduleName
            items = for item in @model.items
                cons: TextContainer
                text: item.name
                valign: 'top'
                align: 'left'
                color: [0,0,0]
                frameColor: [1,1,1]
                roundFrame: breadcrumbHeigth/2
            @updateDef 'items', children: items

            # domElem = @def('root').getDomElement()
            # domElem.innerHTML = ''
            # container = document.createElement 'div'
            # container.className = style.luna ['breadcrumbs', 'noselect']
            # @model.items[0] ?= name: nullModuleNameError
            # if @model.items[0].name == ''
            #     @model.items[0].name = @model.moduleName
            # @model.items.forEach (item) =>
            #     container.appendChild @__renderItem item
            # domElem.appendChild container

    adjust: (view) =>
        if @changed.once
            @withScene (scene) =>
                view.position.y = scene.height

    # __renderItem: (item) =>
    #     div = document.createElement 'div'
    #     div.className = style.luna ['breadcrumbs__item', 'breadcrumbs__item--home']
    #     div.innerHTML = item.name
    #     if item.breadcrumb?
    #         div.addEventListener 'click', => @pushEvent
    #             tag: 'NavigateEvent'
    #             to: item.breadcrumb
    #     return div
