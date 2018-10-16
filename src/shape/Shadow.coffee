import * as basegl from 'basegl'
import * as Color  from 'basegl/display/Color'

export shadowExpr = (base, radius, style) -> basegl.expr ->
    shadow = base.blur radius, style.node_shadowPower
        .fill Color.rgb [0, 0, 0, style.node_shadowOpacity]
    shadow - base
