import {BasicComponent}  from 'abstract/BasicComponent'
import * as basegl       from 'basegl'


export class HtmlShape extends BasicComponent
    initModel: =>
        id: null
        element: 'div'
        top: true
        scalable: true
        still: false
        clickable: true

    redefineRequired: =>
        @changed.id or @changed.element

    define: =>
        root = document.createElement @model.element
        root.id = @model.id if @model.id?
        root.style.pointerEvents = if @model.clickable then 'all' else 'none'
        basegl.symbol root

    adjust: =>
        if @changed.top or @changed.scalable
            obj = @getElement().obj
            if @model.still
                @root.topDomSceneStill.model.add obj
            else if not @model.scalable
                @root.topDomSceneNoScale.model.add obj
            else if @model.top
                @root.topDomScene.model.add obj
            else
                @root.scene.domModel.model.add @view.obj
            @__forceUpdatePosition()

    # FIXME: This function is needed due to bug in basegl or THREE.js
    # which causes problems with positioning when layer changed
    __forceUpdatePosition: =>
        if @getElement()?
            elem = @getElement()
            elem.position.y = if elem.position.y == 0 then 1 else 0
