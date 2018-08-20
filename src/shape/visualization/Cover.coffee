import * as basegl      from 'basegl'
import * as Animation   from 'basegl/animation/Animation'
import * as Easing      from 'basegl/animation/Easing'
import * as Color       from 'basegl/display/Color'
import {rect, plane}    from 'basegl/display/Shape'
import {BasicComponent} from 'abstract/BasicComponent'
import * as style       from 'style'
import * as layers      from 'view/layers'
import * as color       from 'shape/Color'


export width  = 300
export height = 300

export visualizationCoverShape = basegl.expr ->
    shape = plane()
    shape = shape.fill color.activeArea
    shape = shape.move height/2, width/2

visualizationCoverSymbol               = basegl.symbol visualizationCoverShape
visualizationCoverSymbol.defaultZIndex = layers.visualizationCover
visualizationCoverSymbol.bbox.xy       = [width, height]

export class VisualizationCoverShape extends BasicComponent
    define: => visualizationCoverSymbol
    adjust: (element) =>
        element.position.y = -height
