import {BasicComponent}  from 'abstract/BasicComponent'
import * as basegl       from 'basegl'


export class HtmlShape extends BasicComponent
    initModel: =>
        id: null
        element: 'div'
        style: null
        top: true
        scalable: true
        still: false

    redefineRequired: =>
        @changed.id or @changed.element

    define: =>
        root = document.createElement @model.element
        root.id = @model.id if @model.id?
        root.style = @model.style if @model.style?
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
                @__forceUpdatePosition()
            else
                @root._scene.domModel.model.add @__element.obj

    # FIXME: This function is needed due to bug in basegl or THREE.js
    # which causes problems with positioning when layer changed
    __forceUpdatePosition: =>
        if @getElement()?
            elem = @getElement()
            elem.position.y = if elem.position.y == 0 then 1 else 0