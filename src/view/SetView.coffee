import {ContainerComponent} from 'abstract/ContainerComponent'


export class SetView extends ContainerComponent
    initModel: =>
        elems: {}
        cons: null

    update: =>
        if @changed.elems or @changed.cons
            @deleteDefs()
            for k, elem of @model.elems
                @addDef k, new @model.cons elem, @

