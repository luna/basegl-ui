import {ContainerComponent} from 'abstract/ContainerComponent'


export class SetView extends ContainerComponent
    initModel: =>
        elems: {}
        cons: null

    update: =>
        if @changed.cons
            @deleteDefs()
        if @changed.elems
            for own key of @__defs
                unless @model.elems[key]?
                    @deleteDef key
            for k, elem of @model.elems
                @autoUpdateDef k, @model.cons, elem

