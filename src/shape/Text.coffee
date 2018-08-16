import * as basegl from 'basegl'
import {BasicComponent}  from 'abstract/BasicComponent'
import {ContainerComponent}  from 'abstract/ContainerComponent'


export class TextShape extends BasicComponent
    initModel: =>
        text: ''
        align: 'center'

    redefineRequired: =>
        @changed.text

    define: =>
        createText str: @model.text

    adjust: (element) =>
        size = @size()
        element.position.x =
            if @model.align == 'center'
                -size[0] / 2
            else if @model.align == 'right'
                -size[0]
            else
                0
        element.position.y = - size[1]/2

    size:   => getTextSize   @__element
    width:  => getTextWidth  @__element
    height: => getTextHeight @__element

getTextWidth = (textGroup) =>
    textMinX = undefined
    textMaxX = undefined
    textGroup.children.forEach (child) =>
        l = child.position.x
        r = child.position.x + child.bbox.x
        textMinX = l unless l > textMinX
        textMaxX = r unless r < textMaxX
    (textMaxX - textMinX) or 0


getTextHeight = (textGroup) =>
    textMinY = undefined
    textMaxY = undefined
    textGroup.children.forEach (child) =>
        b = child.position.y
        t = child.position.y + child.bbox.y
        textMinY = b unless b > textMinY
        textMaxY = t unless t < textMaxY
    (textMaxY - textMinY) or 0

getTextSize = (textGroup) =>
    textMinX = undefined
    textMaxX = undefined
    textMinY = undefined
    textMaxY = undefined
    textGroup.children.forEach (child) =>
        l = child.position.x
        r = child.position.x + child.bbox.x
        textMinX = l unless l > textMinX
        textMaxX = r unless r < textMaxX
        b = child.position.y
        t = child.position.y + child.bbox.y
        textMinY = b unless b > textMinY
        textMaxY = t unless t < textMaxY
    [(textMaxX - textMinX) or 0, (textMaxY - textMinY) or 0]

createText = (attrs) =>
    addToScene: (scene) =>
        attrs.scene = scene
        attrs.str        ?= ''
        attrs.fontFamily ?= 'DejaVuSansMono'
        attrs.size       ?= 12
        basegl.text attrs
