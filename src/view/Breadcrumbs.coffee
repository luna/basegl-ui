import {Component}    from 'view/Component'
import * as basegl from 'basegl'
import * as style  from 'style'


breadcrumbsId = 'breadcrumbs'
nullModuleNameError = 'No file selected'

export class Breadcrumbs extends Component
    updateModel: ({ moduleName: @moduleName = @moduleName
                  , items:      @items      = @items or []
                  , position:   @position   = @position or [0,0]
                  }) =>
        unless @def?
            root = document.createElement 'div'
            root.className = 'foo bar'
            root.id = breadcrumbsId
            @def = basegl.symbol root

    updateView: =>
        @view.position.xy = @position.slice()
        @view.domElement.innerHTML = ''
        container = document.createElement 'div'
        container.className = style.luna ['breadcrumbs', 'noselect']
        container.appendChild @renderItem (@moduleName or nullModuleNameError)
        @items.forEach (item) =>
            container.appendChild @renderItem item
        @view.domElement.appendChild container

    renderItem: (item) =>
        div = document.createElement 'div'
        div.className = style.luna ['breadcrumbs__item', 'breadcrumbs__item--home']
        div.innerHTML = item
        return div


    getPosition: (scene) =>
        campos = scene.camera.position
        return [ scene.width/2 + campos.x - scene.width/2*campos.z
               , scene.height + campos.y]

    registerEvents: =>
        @withScene (scene) =>
            scene.domElement.addEventListener 'mousemove', (e) =>
                @set position: @getPosition scene
