import {Component}    from 'view/Component'
import * as basegl from 'basegl'
import * as style  from 'style'


breadcrumbsId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

export class Breadcrumbs extends Component
    updateModel: ({ moduleName: @moduleName = @moduleName
                  , items:      @items      = @items or []
                  }) =>
    unless @def?
        root = document.createElement 'div'
        root.className = 'foo bar'
        root.id = breadcrumbsId
        root.style.width = 100 + 'px'
        root.style.height = 200 + 'px'
        @def = basegl.symbol root

    updateView: =>
        @view.domElement.innerHTML = ''
        container = document.createElement 'div'
        container.className = style.luna ['breadcrumbs', 'noselect']
        if @items.length == 0
            container.appendChild @renderEmpty (@moduleName or nullModuleNameError)
        else items.forEach (item) =>
            container.appendChild @renderItem item
        @view.domElement.appendChild container

    renderItem: (item) =>
        div = document.createElement 'div'
        div.className = style.luna ['breadcrumbs__item']
        div.innerHTML = item
        return div
