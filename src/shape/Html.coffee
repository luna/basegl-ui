import {BasicComponent}  from 'abstract/BasicComponent'
import * as basegl       from 'basegl'


export class HtmlShape extends BasicComponent
    initModel: =>
        id: null
        element: 'div'
        width: null
        height: null
        top: true
        scalable: true
        still: false
        clickable: true

    redefineRequired: =>
        @changed.id or @changed.element or @changed.width or @changed.height or @changed.clickable

    define: =>
        html = document.createElement @model.element
        html.id = @model.id if @model.id?
        html.style.width = @model.width if @model.width?
        html.style.height = @model.height if @model.height?
        html.style.pointerEvents = if @model.clickable then 'all' else 'none'
        basegl.symbol html

    adjust: =>
        if @redefineRequired()
            obj = @getElement().obj
            if @model.still
                @root.topDomSceneStill.model.add obj
            else if not @model.scalable
                @root.topDomSceneNoScale.model.add obj
            else if @model.top
                @root.topDomScene.model.add obj
            else
                @root._scene.domModel.model.add @__element.obj
            @__forceUpdatePosition()

    # FIXME: This function is needed due to bug in basegl or THREE.js
    # which causes problems with positioning when layer changed
    __forceUpdatePosition: =>
        elem = @getElement()
        if elem?
            elem.position.y = if elem.position.y == 0 then 1 else 0
