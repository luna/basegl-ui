import {Composable}             from "basegl/object/Property"


export class Disposable extends Composable
    cons: =>
        @disposables = []
        @disposed = false

    dispose: =>
        @fireDisposables()
        @destruct?()
        @disposed = true

    addDisposableListener: (target, name, handler) =>
        target.addEventListener name, handler
        @onDispose => target.removeEventListener name, handler

    onDispose: (finalizer) =>
        @disposables.push finalizer

    fireDisposables: =>
        @disposables.forEach (disposable) =>
            disposable()
        @disposables = []