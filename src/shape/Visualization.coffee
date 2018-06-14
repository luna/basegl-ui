import * as basegl    from 'basegl'
import * as Animation from 'basegl/animation/Animation'
import * as Easing    from 'basegl/animation/Easing'
import * as Color     from 'basegl/display/Color'
import {rect, plane}  from 'basegl/display/Shape'
import * as style     from 'style'


# white       = Color.rgb [1,1,1]
transparent = Color.rgb [0,0,0,0]

export width  = 300
export height = 300


__mkVisualizationDiv = ->
    div              = document.createElement 'div'
    div.style.width  = width + 'px'
    div.style.height = height + 'px'
    div

export visualizationDiv = __mkVisualizationDiv()

__mkMenuTogglerDiv = ->
    div           = document.createElement 'div'
    div.innerHTML = '▾'
    div.className = style.luna ['dropdown']
    div

export menuTogglerDiv = __mkMenuTogglerDiv()

export visualizationCoverShape = basegl.expr ->
    shape = plane()
    shape = shape.fill transparent
    shape = shape.move height/2, width/2