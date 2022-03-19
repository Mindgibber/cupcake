const _main = {
    _wasms: new _Objs(),
    _textDecoder: new TextDecoder(),

    _run(_wasmPath, _canvasParent) {
        const _imports = {};
        _imports.env = {
            ..._main,
            ..._res,
            ..._app,
            ..._webgpu,
        };

        fetch(_wasmPath)
            .then(_response => _response.arrayBuffer())
            .then(_arrayBuffer => WebAssembly.instantiate(_arrayBuffer, _imports))
            .then(_results => {
                _app._setCanvasParent(_canvasParent);
                const _wasmId = _main._wasms._insert({
                    _obj: _results.instance.exports,
                    _canUpdate: false,
                });
                _main._wasms._get(_wasmId)._obj.init(_wasmId);
                window.requestAnimationFrame(_main._update);
            })
            .catch(_err => console.log(_err));
    },

    _update(_timestamp) {
        //console.log(performance.memory.totalJSHeapSize);
        for (let i = _main._wasms._begin();
            i < _main._wasms._end();
            i = _main._wasms._next(i))
        {
            if (_main._wasms._get(i)._canUpdate) {
                _main._wasms._get(i)._obj.update();
            }
        }
        window.requestAnimationFrame(_main._update);
    },

    _u8Array(_wasmId, _ptr, _len) {
        return new Uint8Array(_main._wasms._get(_wasmId)._obj.memory.buffer, _ptr, _len);
    },

    _u32Array(_wasmId, _ptr, _len) {
        return new Uint32Array(_main._wasms._get(_wasmId)._obj.memory.buffer, _ptr, _len / 4);
    },

    _getString(_wasmId, _ptr, _len) {
        return _main._textDecoder.decode(_main._u8Array(_wasmId, _ptr, _len));
    },

    logConsole(_wasmId, _msgPtr, _msgLen) {
        console.log(_main._getString(_wasmId, _msgPtr, _msgLen));
    },
};

function run(_wasmPath, _canvasParent) {
    _main._run(_wasmPath, _canvasParent);
}
