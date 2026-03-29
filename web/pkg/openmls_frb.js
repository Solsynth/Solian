let wasm_bindgen = (function(exports) {
    let script_src;
    if (typeof document !== 'undefined' && document.currentScript !== null) {
        script_src = new URL(document.currentScript.src, location.href).toString();
    }

    /**
     * Runtime test harness support instantiated in JS.
     *
     * The node.js entry script instantiates a `Context` here which is used to
     * drive test execution.
     */
    class WasmBindgenTestContext {
        __destroy_into_raw() {
            const ptr = this.__wbg_ptr;
            this.__wbg_ptr = 0;
            WasmBindgenTestContextFinalization.unregister(this);
            return ptr;
        }
        free() {
            const ptr = this.__destroy_into_raw();
            wasm.__wbg_wasmbindgentestcontext_free(ptr, 0);
        }
        /**
         * Handle filter argument.
         * @param {number} filtered
         */
        filtered_count(filtered) {
            wasm.wasmbindgentestcontext_filtered_count(this.__wbg_ptr, filtered);
        }
        /**
         * Handle `--include-ignored` flag.
         * @param {boolean} include_ignored
         */
        include_ignored(include_ignored) {
            wasm.wasmbindgentestcontext_include_ignored(this.__wbg_ptr, include_ignored);
        }
        /**
         * Creates a new context ready to run tests.
         *
         * A `Context` is the main structure through which test execution is
         * coordinated, and this will collect output and results for all executed
         * tests.
         * @param {boolean} is_bench
         */
        constructor(is_bench) {
            const ret = wasm.wasmbindgentestcontext_new(is_bench);
            this.__wbg_ptr = ret >>> 0;
            WasmBindgenTestContextFinalization.register(this, this.__wbg_ptr, this);
            return this;
        }
        /**
         * Executes a list of tests, returning a promise representing their
         * eventual completion.
         *
         * This is the main entry point for executing tests. All the tests passed
         * in are the JS `Function` object that was plucked off the
         * `WebAssembly.Instance` exports list.
         *
         * The promise returned resolves to either `true` if all tests passed or
         * `false` if at least one test failed.
         * @param {any[]} tests
         * @returns {Promise<any>}
         */
        run(tests) {
            const ptr0 = passArrayJsValueToWasm0(tests, wasm.__wbindgen_export);
            const len0 = WASM_VECTOR_LEN;
            const ret = wasm.wasmbindgentestcontext_run(this.__wbg_ptr, ptr0, len0);
            return takeObject(ret);
        }
    }
    if (Symbol.dispose) WasmBindgenTestContext.prototype[Symbol.dispose] = WasmBindgenTestContext.prototype.free;
    exports.WasmBindgenTestContext = WasmBindgenTestContext;

    class WorkerPool {
        static __wrap(ptr) {
            ptr = ptr >>> 0;
            const obj = Object.create(WorkerPool.prototype);
            obj.__wbg_ptr = ptr;
            WorkerPoolFinalization.register(obj, obj.__wbg_ptr, obj);
            return obj;
        }
        __destroy_into_raw() {
            const ptr = this.__wbg_ptr;
            this.__wbg_ptr = 0;
            WorkerPoolFinalization.unregister(this);
            return ptr;
        }
        free() {
            const ptr = this.__destroy_into_raw();
            wasm.__wbg_workerpool_free(ptr, 0);
        }
        /**
         * @param {number | null} [initial]
         * @param {string | null} [script_src]
         * @param {string | null} [worker_js_preamble]
         * @returns {WorkerPool}
         */
        static new(initial, script_src, worker_js_preamble) {
            try {
                const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
                var ptr0 = isLikeNone(script_src) ? 0 : passStringToWasm0(script_src, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                var len0 = WASM_VECTOR_LEN;
                var ptr1 = isLikeNone(worker_js_preamble) ? 0 : passStringToWasm0(worker_js_preamble, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                var len1 = WASM_VECTOR_LEN;
                wasm.workerpool_new(retptr, isLikeNone(initial) ? 0x100000001 : (initial) >>> 0, ptr0, len0, ptr1, len1);
                var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
                var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
                var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
                if (r2) {
                    throw takeObject(r1);
                }
                return WorkerPool.__wrap(r0);
            } finally {
                wasm.__wbindgen_add_to_stack_pointer(16);
            }
        }
        /**
         * Creates a new `WorkerPool` which immediately creates `initial` workers.
         *
         * The pool created here can be used over a long period of time, and it
         * will be initially primed with `initial` workers. Currently workers are
         * never released or gc'd until the whole pool is destroyed.
         *
         * # Errors
         *
         * Returns any error that may happen while a JS web worker is created and a
         * message is sent to it.
         * @param {number} initial
         * @param {string} script_src
         * @param {string} worker_js_preamble
         */
        constructor(initial, script_src, worker_js_preamble) {
            try {
                const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
                const ptr0 = passStringToWasm0(script_src, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len0 = WASM_VECTOR_LEN;
                const ptr1 = passStringToWasm0(worker_js_preamble, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                wasm.workerpool_new_raw(retptr, initial, ptr0, len0, ptr1, len1);
                var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
                var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
                var r2 = getDataViewMemory0().getInt32(retptr + 4 * 2, true);
                if (r2) {
                    throw takeObject(r1);
                }
                this.__wbg_ptr = r0 >>> 0;
                WorkerPoolFinalization.register(this, this.__wbg_ptr, this);
                return this;
            } finally {
                wasm.__wbindgen_add_to_stack_pointer(16);
            }
        }
    }
    if (Symbol.dispose) WorkerPool.prototype[Symbol.dispose] = WorkerPool.prototype.free;
    exports.WorkerPool = WorkerPool;

    /**
     * Used to read benchmark data, and then the runner stores it on the local disk.
     * @returns {Uint8Array | undefined}
     */
    function __wbgbench_dump() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.__wbgbench_dump(retptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            let v1;
            if (r0 !== 0) {
                v1 = getArrayU8FromWasm0(r0, r1).slice();
                wasm.__wbindgen_export4(r0, r1 * 1, 1);
            }
            return v1;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    exports.__wbgbench_dump = __wbgbench_dump;

    /**
     * Used to write previous benchmark data before the benchmark, for later comparison.
     * @param {Uint8Array} baseline
     */
    function __wbgbench_import(baseline) {
        const ptr0 = passArray8ToWasm0(baseline, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.__wbgbench_import(ptr0, len0);
    }
    exports.__wbgbench_import = __wbgbench_import;

    /**
     * Handler for `console.debug` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_debug(args) {
        try {
            wasm.__wbgtest_console_debug(addBorrowedObject(args));
        } finally {
            heap[stack_pointer++] = undefined;
        }
    }
    exports.__wbgtest_console_debug = __wbgtest_console_debug;

    /**
     * Handler for `console.error` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_error(args) {
        try {
            wasm.__wbgtest_console_debug(addBorrowedObject(args));
        } finally {
            heap[stack_pointer++] = undefined;
        }
    }
    exports.__wbgtest_console_error = __wbgtest_console_error;

    /**
     * Handler for `console.info` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_info(args) {
        try {
            wasm.__wbgtest_console_debug(addBorrowedObject(args));
        } finally {
            heap[stack_pointer++] = undefined;
        }
    }
    exports.__wbgtest_console_info = __wbgtest_console_info;

    /**
     * Handler for `console.log` invocations.
     *
     * If a test is currently running it takes the `args` array and stringifies
     * it and appends it to the current output of the test. Otherwise it passes
     * the arguments to the original `console.log` function, psased as
     * `original`.
     * @param {Array<any>} args
     */
    function __wbgtest_console_log(args) {
        try {
            wasm.__wbgtest_console_debug(addBorrowedObject(args));
        } finally {
            heap[stack_pointer++] = undefined;
        }
    }
    exports.__wbgtest_console_log = __wbgtest_console_log;

    /**
     * Handler for `console.warn` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_warn(args) {
        try {
            wasm.__wbgtest_console_debug(addBorrowedObject(args));
        } finally {
            heap[stack_pointer++] = undefined;
        }
    }
    exports.__wbgtest_console_warn = __wbgtest_console_warn;

    /**
     * @returns {Uint8Array | undefined}
     */
    function __wbgtest_cov_dump() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.__wbgtest_cov_dump(retptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            let v1;
            if (r0 !== 0) {
                v1 = getArrayU8FromWasm0(r0, r1).slice();
                wasm.__wbindgen_export4(r0, r1 * 1, 1);
            }
            return v1;
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    exports.__wbgtest_cov_dump = __wbgtest_cov_dump;

    /**
     * Path to use for coverage data.
     * @param {string | null | undefined} env
     * @param {number} pid
     * @param {string} temp_dir
     * @param {bigint} module_signature
     * @returns {string}
     */
    function __wbgtest_coverage_path(env, pid, temp_dir, module_signature) {
        let deferred3_0;
        let deferred3_1;
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            var ptr0 = isLikeNone(env) ? 0 : passStringToWasm0(env, wasm.__wbindgen_export, wasm.__wbindgen_export2);
            var len0 = WASM_VECTOR_LEN;
            const ptr1 = passStringToWasm0(temp_dir, wasm.__wbindgen_export, wasm.__wbindgen_export2);
            const len1 = WASM_VECTOR_LEN;
            wasm.__wbgtest_coverage_path(retptr, ptr0, len0, pid, ptr1, len1, module_signature);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            deferred3_0 = r0;
            deferred3_1 = r1;
            return getStringFromWasm0(r0, r1);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
            wasm.__wbindgen_export4(deferred3_0, deferred3_1, 1);
        }
    }
    exports.__wbgtest_coverage_path = __wbgtest_coverage_path;

    /**
     * @returns {bigint | undefined}
     */
    function __wbgtest_module_signature() {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            wasm.__wbgtest_module_signature(retptr);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r2 = getDataViewMemory0().getBigInt64(retptr + 8 * 1, true);
            return r0 === 0 ? undefined : BigInt.asUintN(64, r2);
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    exports.__wbgtest_module_signature = __wbgtest_module_signature;

    /**
     * @param {number} call_id
     * @param {any} ptr_
     * @param {number} rust_vec_len_
     * @param {number} data_len_
     */
    function frb_dart_fn_deliver_output(call_id, ptr_, rust_vec_len_, data_len_) {
        wasm.frb_dart_fn_deliver_output(call_id, addHeapObject(ptr_), rust_vec_len_, data_len_);
    }
    exports.frb_dart_fn_deliver_output = frb_dart_fn_deliver_output;

    /**
     * # Safety
     *
     * This should never be called manually.
     * @param {any} handle
     * @param {any} dart_handler_port
     * @returns {number}
     */
    function frb_dart_opaque_dart2rust_encode(handle, dart_handler_port) {
        const ret = wasm.frb_dart_opaque_dart2rust_encode(addHeapObject(handle), addHeapObject(dart_handler_port));
        return ret >>> 0;
    }
    exports.frb_dart_opaque_dart2rust_encode = frb_dart_opaque_dart2rust_encode;

    /**
     * @param {number} ptr
     */
    function frb_dart_opaque_drop_thread_box_persistent_handle(ptr) {
        wasm.frb_dart_opaque_drop_thread_box_persistent_handle(ptr);
    }
    exports.frb_dart_opaque_drop_thread_box_persistent_handle = frb_dart_opaque_drop_thread_box_persistent_handle;

    /**
     * @param {number} ptr
     * @returns {any}
     */
    function frb_dart_opaque_rust2dart_decode(ptr) {
        const ret = wasm.frb_dart_opaque_rust2dart_decode(ptr);
        return takeObject(ret);
    }
    exports.frb_dart_opaque_rust2dart_decode = frb_dart_opaque_rust2dart_decode;

    /**
     * @returns {number}
     */
    function frb_get_rust_content_hash() {
        const ret = wasm.frb_get_rust_content_hash();
        return ret;
    }
    exports.frb_get_rust_content_hash = frb_get_rust_content_hash;

    /**
     * @param {number} func_id
     * @param {any} port_
     * @param {any} ptr_
     * @param {number} rust_vec_len_
     * @param {number} data_len_
     */
    function frb_pde_ffi_dispatcher_primary(func_id, port_, ptr_, rust_vec_len_, data_len_) {
        wasm.frb_pde_ffi_dispatcher_primary(func_id, addHeapObject(port_), addHeapObject(ptr_), rust_vec_len_, data_len_);
    }
    exports.frb_pde_ffi_dispatcher_primary = frb_pde_ffi_dispatcher_primary;

    /**
     * @param {number} func_id
     * @param {any} ptr_
     * @param {number} rust_vec_len_
     * @param {number} data_len_
     * @returns {any}
     */
    function frb_pde_ffi_dispatcher_sync(func_id, ptr_, rust_vec_len_, data_len_) {
        const ret = wasm.frb_pde_ffi_dispatcher_sync(func_id, addHeapObject(ptr_), rust_vec_len_, data_len_);
        return takeObject(ret);
    }
    exports.frb_pde_ffi_dispatcher_sync = frb_pde_ffi_dispatcher_sync;

    /**
     * ## Safety
     * This function reclaims a raw pointer created by [`TransferClosure`], and therefore
     * should **only** be used in conjunction with it.
     * Furthermore, the WASM module in the worker must have been initialized with the shared
     * memory from the host JS scope.
     * @param {number} payload
     * @param {any[]} transfer
     */
    function receive_transfer_closure(payload, transfer) {
        try {
            const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
            const ptr0 = passArrayJsValueToWasm0(transfer, wasm.__wbindgen_export);
            const len0 = WASM_VECTOR_LEN;
            wasm.receive_transfer_closure(retptr, payload, ptr0, len0);
            var r0 = getDataViewMemory0().getInt32(retptr + 4 * 0, true);
            var r1 = getDataViewMemory0().getInt32(retptr + 4 * 1, true);
            if (r1) {
                throw takeObject(r0);
            }
        } finally {
            wasm.__wbindgen_add_to_stack_pointer(16);
        }
    }
    exports.receive_transfer_closure = receive_transfer_closure;

    /**
     * @param {number} ptr
     */
    function rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential(ptr) {
        wasm.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential(ptr);
    }
    exports.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential = rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential;

    /**
     * @param {number} ptr
     */
    function rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine(ptr) {
        wasm.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine(ptr);
    }
    exports.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine = rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine;

    /**
     * @param {number} ptr
     */
    function rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair(ptr) {
        wasm.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair(ptr);
    }
    exports.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair = rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair;

    /**
     * @param {number} ptr
     */
    function rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential(ptr) {
        wasm.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential(ptr);
    }
    exports.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential = rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential;

    /**
     * @param {number} ptr
     */
    function rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine(ptr) {
        wasm.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential(ptr);
    }
    exports.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine = rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine;

    /**
     * @param {number} ptr
     */
    function rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair(ptr) {
        wasm.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsCredential(ptr);
    }
    exports.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair = rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair;

    function wasm_start_callback() {
        wasm.wasm_start_callback();
    }
    exports.wasm_start_callback = wasm_start_callback;

    /**
     * @param {number} ciphersuite
     * @returns {any}
     */
    function wire__crate__api__config__mls_group_config_default_config(ciphersuite) {
        const ret = wasm.wire__crate__api__config__mls_group_config_default_config(ciphersuite);
        return takeObject(ret);
    }
    exports.wire__crate__api__config__mls_group_config_default_config = wire__crate__api__config__mls_group_config_default_config;

    /**
     * @param {Uint8Array} identity
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_basic(identity) {
        const ptr0 = passArray8ToWasm0(identity, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__credential__MlsCredential_basic(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_basic = wire__crate__api__credential__MlsCredential_basic;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_certificates(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_certificates(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_certificates = wire__crate__api__credential__MlsCredential_certificates;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_credential_type(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_credential_type(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_credential_type = wire__crate__api__credential__MlsCredential_credential_type;

    /**
     * @param {Uint8Array} bytes
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_deserialize(bytes) {
        const ptr0 = passArray8ToWasm0(bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__credential__MlsCredential_deserialize(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_deserialize = wire__crate__api__credential__MlsCredential_deserialize;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_identity(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_identity(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_identity = wire__crate__api__credential__MlsCredential_identity;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_serialize(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_serialize(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_serialize = wire__crate__api__credential__MlsCredential_serialize;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_serialized_content(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_serialized_content(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_serialized_content = wire__crate__api__credential__MlsCredential_serialized_content;

    /**
     * @param {any} certificate_chain
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_x509(certificate_chain) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_x509(addHeapObject(certificate_chain));
        return takeObject(ret);
    }
    exports.wire__crate__api__credential__MlsCredential_x509 = wire__crate__api__credential__MlsCredential_x509;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {any} key_packages_bytes
     */
    function wire__crate__api__engine__MlsEngine_add_members(port_, that, group_id_bytes, signer_bytes, key_packages_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_add_members(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, addHeapObject(key_packages_bytes));
    }
    exports.wire__crate__api__engine__MlsEngine_add_members = wire__crate__api__engine__MlsEngine_add_members;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {any} key_packages_bytes
     */
    function wire__crate__api__engine__MlsEngine_add_members_without_update(port_, that, group_id_bytes, signer_bytes, key_packages_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_add_members_without_update(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, addHeapObject(key_packages_bytes));
    }
    exports.wire__crate__api__engine__MlsEngine_add_members_without_update = wire__crate__api__engine__MlsEngine_add_members_without_update;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_clear_pending_commit(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_clear_pending_commit(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_clear_pending_commit = wire__crate__api__engine__MlsEngine_clear_pending_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_clear_pending_proposals(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_clear_pending_proposals(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_clear_pending_proposals = wire__crate__api__engine__MlsEngine_clear_pending_proposals;

    /**
     * @param {any} port_
     * @param {any} that
     */
    function wire__crate__api__engine__MlsEngine_close(port_, that) {
        wasm.wire__crate__api__engine__MlsEngine_close(addHeapObject(port_), addHeapObject(that));
    }
    exports.wire__crate__api__engine__MlsEngine_close = wire__crate__api__engine__MlsEngine_close;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_commit_to_pending_proposals(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_commit_to_pending_proposals(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_commit_to_pending_proposals = wire__crate__api__engine__MlsEngine_commit_to_pending_proposals;

    /**
     * @param {any} port_
     * @param {string} db_path
     * @param {Uint8Array} encryption_key
     */
    function wire__crate__api__engine__MlsEngine_create(port_, db_path, encryption_key) {
        const ptr0 = passStringToWasm0(db_path, wasm.__wbindgen_export, wasm.__wbindgen_export2);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(encryption_key, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create(addHeapObject(port_), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_create = wire__crate__api__engine__MlsEngine_create;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_identity
     * @param {Uint8Array} signer_public_key
     * @param {Uint8Array | null} [group_id]
     * @param {Uint8Array | null} [credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_create_group(port_, that, config, signer_bytes, credential_identity, signer_public_key, group_id, credential_bytes) {
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(group_id) ? 0 : passArray8ToWasm0(group_id, wasm.__wbindgen_export);
        var len3 = WASM_VECTOR_LEN;
        var ptr4 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        var len4 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_group(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4);
    }
    exports.wire__crate__api__engine__MlsEngine_create_group = wire__crate__api__engine__MlsEngine_create_group;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_identity
     * @param {Uint8Array} signer_public_key
     * @param {Uint8Array | null | undefined} group_id
     * @param {any} lifetime_seconds
     * @param {any} group_context_extensions
     * @param {any} leaf_node_extensions
     * @param {any} capabilities
     * @param {Uint8Array | null} [credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_create_group_with_builder(port_, that, config, signer_bytes, credential_identity, signer_public_key, group_id, lifetime_seconds, group_context_extensions, leaf_node_extensions, capabilities, credential_bytes) {
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(group_id) ? 0 : passArray8ToWasm0(group_id, wasm.__wbindgen_export);
        var len3 = WASM_VECTOR_LEN;
        var ptr4 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        var len4 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_group_with_builder(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, addHeapObject(lifetime_seconds), addHeapObject(group_context_extensions), addHeapObject(leaf_node_extensions), addHeapObject(capabilities), ptr4, len4);
    }
    exports.wire__crate__api__engine__MlsEngine_create_group_with_builder = wire__crate__api__engine__MlsEngine_create_group_with_builder;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {number} ciphersuite
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_identity
     * @param {Uint8Array} signer_public_key
     * @param {Uint8Array | null} [credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_create_key_package(port_, that, ciphersuite, signer_bytes, credential_identity, signer_public_key, credential_bytes) {
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        var len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_key_package(addHeapObject(port_), addHeapObject(that), ciphersuite, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
    }
    exports.wire__crate__api__engine__MlsEngine_create_key_package = wire__crate__api__engine__MlsEngine_create_key_package;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {number} ciphersuite
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_identity
     * @param {Uint8Array} signer_public_key
     * @param {any} options
     * @param {Uint8Array | null} [credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_create_key_package_with_options(port_, that, ciphersuite, signer_bytes, credential_identity, signer_public_key, options, credential_bytes) {
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        var len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_key_package_with_options(addHeapObject(port_), addHeapObject(that), ciphersuite, ptr0, len0, ptr1, len1, ptr2, len2, addHeapObject(options), ptr3, len3);
    }
    exports.wire__crate__api__engine__MlsEngine_create_key_package_with_options = wire__crate__api__engine__MlsEngine_create_key_package_with_options;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} message
     * @param {Uint8Array | null} [aad]
     */
    function wire__crate__api__engine__MlsEngine_create_message(port_, that, group_id_bytes, signer_bytes, message, aad) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(message, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(aad) ? 0 : passArray8ToWasm0(aad, wasm.__wbindgen_export);
        var len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_message(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
    }
    exports.wire__crate__api__engine__MlsEngine_create_message = wire__crate__api__engine__MlsEngine_create_message;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_delete_group(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_delete_group(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_delete_group = wire__crate__api__engine__MlsEngine_delete_group;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} key_package_ref_bytes
     */
    function wire__crate__api__engine__MlsEngine_delete_key_package(port_, that, key_package_ref_bytes) {
        const ptr0 = passArray8ToWasm0(key_package_ref_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_delete_key_package(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_delete_key_package = wire__crate__api__engine__MlsEngine_delete_key_package;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_export_group_context(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_group_context(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_export_group_context = wire__crate__api__engine__MlsEngine_export_group_context;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_export_group_info(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_group_info(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_export_group_info = wire__crate__api__engine__MlsEngine_export_group_info;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_export_ratchet_tree(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_ratchet_tree(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_export_ratchet_tree = wire__crate__api__engine__MlsEngine_export_ratchet_tree;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {string} label
     * @param {Uint8Array} context
     * @param {number} key_length
     */
    function wire__crate__api__engine__MlsEngine_export_secret(port_, that, group_id_bytes, label, context, key_length) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(label, wasm.__wbindgen_export, wasm.__wbindgen_export2);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(context, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_secret(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2, key_length);
    }
    exports.wire__crate__api__engine__MlsEngine_export_secret = wire__crate__api__engine__MlsEngine_export_secret;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {any} options
     */
    function wire__crate__api__engine__MlsEngine_flexible_commit(port_, that, group_id_bytes, signer_bytes, options) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_flexible_commit(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, addHeapObject(options));
    }
    exports.wire__crate__api__engine__MlsEngine_flexible_commit = wire__crate__api__engine__MlsEngine_flexible_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {any} epoch
     */
    function wire__crate__api__engine__MlsEngine_get_past_resumption_psk(port_, that, group_id_bytes, epoch) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_get_past_resumption_psk(addHeapObject(port_), addHeapObject(that), ptr0, len0, addHeapObject(epoch));
    }
    exports.wire__crate__api__engine__MlsEngine_get_past_resumption_psk = wire__crate__api__engine__MlsEngine_get_past_resumption_psk;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_ciphersuite(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_ciphersuite(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_ciphersuite = wire__crate__api__engine__MlsEngine_group_ciphersuite;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_configuration(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_configuration(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_configuration = wire__crate__api__engine__MlsEngine_group_configuration;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_confirmation_tag(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_confirmation_tag(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_confirmation_tag = wire__crate__api__engine__MlsEngine_group_confirmation_tag;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_credential(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_credential(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_credential = wire__crate__api__engine__MlsEngine_group_credential;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_epoch(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_epoch(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_epoch = wire__crate__api__engine__MlsEngine_group_epoch;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_epoch_authenticator(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_epoch_authenticator(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_epoch_authenticator = wire__crate__api__engine__MlsEngine_group_epoch_authenticator;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_extensions(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_extensions(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_extensions = wire__crate__api__engine__MlsEngine_group_extensions;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_has_pending_proposals(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_has_pending_proposals(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_has_pending_proposals = wire__crate__api__engine__MlsEngine_group_has_pending_proposals;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_id(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_id(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_id = wire__crate__api__engine__MlsEngine_group_id;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_is_active(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_is_active(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_is_active = wire__crate__api__engine__MlsEngine_group_is_active;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {number} leaf_index
     */
    function wire__crate__api__engine__MlsEngine_group_member_at(port_, that, group_id_bytes, leaf_index) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_member_at(addHeapObject(port_), addHeapObject(that), ptr0, len0, leaf_index);
    }
    exports.wire__crate__api__engine__MlsEngine_group_member_at = wire__crate__api__engine__MlsEngine_group_member_at;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} credential_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_member_leaf_index(port_, that, group_id_bytes, credential_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_member_leaf_index(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_group_member_leaf_index = wire__crate__api__engine__MlsEngine_group_member_leaf_index;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_members(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_members(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_members = wire__crate__api__engine__MlsEngine_group_members;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_own_index(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_own_index(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_own_index = wire__crate__api__engine__MlsEngine_group_own_index;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_own_leaf_node(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_own_leaf_node(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_own_leaf_node = wire__crate__api__engine__MlsEngine_group_own_leaf_node;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_pending_proposals(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_pending_proposals(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_pending_proposals = wire__crate__api__engine__MlsEngine_group_pending_proposals;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} welcome_bytes
     */
    function wire__crate__api__engine__MlsEngine_inspect_welcome(port_, that, config, welcome_bytes) {
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_inspect_welcome(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_inspect_welcome = wire__crate__api__engine__MlsEngine_inspect_welcome;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__engine__MlsEngine_is_closed(that) {
        const ret = wasm.wire__crate__api__engine__MlsEngine_is_closed(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__engine__MlsEngine_is_closed = wire__crate__api__engine__MlsEngine_is_closed;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} group_info_bytes
     * @param {Uint8Array | null | undefined} ratchet_tree_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_identity
     * @param {Uint8Array} signer_public_key
     * @param {Uint8Array | null} [credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_join_group_external_commit(port_, that, config, group_info_bytes, ratchet_tree_bytes, signer_bytes, credential_identity, signer_public_key, credential_bytes) {
        const ptr0 = passArray8ToWasm0(group_info_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_export);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_export);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_export);
        const len4 = WASM_VECTOR_LEN;
        var ptr5 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        var len5 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_external_commit(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5);
    }
    exports.wire__crate__api__engine__MlsEngine_join_group_external_commit = wire__crate__api__engine__MlsEngine_join_group_external_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} group_info_bytes
     * @param {Uint8Array | null | undefined} ratchet_tree_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_identity
     * @param {Uint8Array} signer_public_key
     * @param {Uint8Array | null | undefined} aad
     * @param {boolean} skip_lifetime_validation
     * @param {Uint8Array | null} [credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_join_group_external_commit_v2(port_, that, config, group_info_bytes, ratchet_tree_bytes, signer_bytes, credential_identity, signer_public_key, aad, skip_lifetime_validation, credential_bytes) {
        const ptr0 = passArray8ToWasm0(group_info_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_export);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_export);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_export);
        const len4 = WASM_VECTOR_LEN;
        var ptr5 = isLikeNone(aad) ? 0 : passArray8ToWasm0(aad, wasm.__wbindgen_export);
        var len5 = WASM_VECTOR_LEN;
        var ptr6 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        var len6 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_external_commit_v2(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, skip_lifetime_validation, ptr6, len6);
    }
    exports.wire__crate__api__engine__MlsEngine_join_group_external_commit_v2 = wire__crate__api__engine__MlsEngine_join_group_external_commit_v2;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} welcome_bytes
     * @param {Uint8Array | null | undefined} ratchet_tree_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_join_group_from_welcome(port_, that, config, welcome_bytes, ratchet_tree_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_export);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_from_welcome(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0, ptr1, len1, ptr2, len2);
    }
    exports.wire__crate__api__engine__MlsEngine_join_group_from_welcome = wire__crate__api__engine__MlsEngine_join_group_from_welcome;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} welcome_bytes
     * @param {Uint8Array | null | undefined} ratchet_tree_bytes
     * @param {Uint8Array} signer_bytes
     * @param {boolean} skip_lifetime_validation
     */
    function wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options(port_, that, config, welcome_bytes, ratchet_tree_bytes, signer_bytes, skip_lifetime_validation) {
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_export);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options(addHeapObject(port_), addHeapObject(that), addHeapObject(config), ptr0, len0, ptr1, len1, ptr2, len2, skip_lifetime_validation);
    }
    exports.wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options = wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_leave_group(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_leave_group(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_leave_group = wire__crate__api__engine__MlsEngine_leave_group;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_leave_group_via_self_remove(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_leave_group_via_self_remove(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_leave_group_via_self_remove = wire__crate__api__engine__MlsEngine_leave_group_via_self_remove;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_merge_pending_commit(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_merge_pending_commit(addHeapObject(port_), addHeapObject(that), ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_merge_pending_commit = wire__crate__api__engine__MlsEngine_merge_pending_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} message_bytes
     */
    function wire__crate__api__engine__MlsEngine_process_message(port_, that, group_id_bytes, message_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_process_message(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_process_message = wire__crate__api__engine__MlsEngine_process_message;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} message_bytes
     */
    function wire__crate__api__engine__MlsEngine_process_message_with_inspect(port_, that, group_id_bytes, message_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_process_message_with_inspect(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_process_message_with_inspect = wire__crate__api__engine__MlsEngine_process_message_with_inspect;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} key_package_bytes
     */
    function wire__crate__api__engine__MlsEngine_propose_add(port_, that, group_id_bytes, signer_bytes, key_package_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(key_package_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_add(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2);
    }
    exports.wire__crate__api__engine__MlsEngine_propose_add = wire__crate__api__engine__MlsEngine_propose_add;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {number} proposal_type
     * @param {Uint8Array} payload
     */
    function wire__crate__api__engine__MlsEngine_propose_custom_proposal(port_, that, group_id_bytes, signer_bytes, proposal_type, payload) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(payload, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_custom_proposal(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, proposal_type, ptr2, len2);
    }
    exports.wire__crate__api__engine__MlsEngine_propose_custom_proposal = wire__crate__api__engine__MlsEngine_propose_custom_proposal;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} psk_id
     * @param {Uint8Array} psk_nonce
     */
    function wire__crate__api__engine__MlsEngine_propose_external_psk(port_, that, group_id_bytes, signer_bytes, psk_id, psk_nonce) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(psk_id, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(psk_nonce, wasm.__wbindgen_export);
        const len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_external_psk(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
    }
    exports.wire__crate__api__engine__MlsEngine_propose_external_psk = wire__crate__api__engine__MlsEngine_propose_external_psk;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {any} extensions
     */
    function wire__crate__api__engine__MlsEngine_propose_group_context_extensions(port_, that, group_id_bytes, signer_bytes, extensions) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_group_context_extensions(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, addHeapObject(extensions));
    }
    exports.wire__crate__api__engine__MlsEngine_propose_group_context_extensions = wire__crate__api__engine__MlsEngine_propose_group_context_extensions;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {number} member_index
     */
    function wire__crate__api__engine__MlsEngine_propose_remove(port_, that, group_id_bytes, signer_bytes, member_index) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_remove(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, member_index);
    }
    exports.wire__crate__api__engine__MlsEngine_propose_remove = wire__crate__api__engine__MlsEngine_propose_remove;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint8Array} credential_bytes
     */
    function wire__crate__api__engine__MlsEngine_propose_remove_member_by_credential(port_, that, group_id_bytes, signer_bytes, credential_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(credential_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_remove_member_by_credential(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2);
    }
    exports.wire__crate__api__engine__MlsEngine_propose_remove_member_by_credential = wire__crate__api__engine__MlsEngine_propose_remove_member_by_credential;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {any} leaf_node_capabilities
     * @param {any} leaf_node_extensions
     */
    function wire__crate__api__engine__MlsEngine_propose_self_update(port_, that, group_id_bytes, signer_bytes, leaf_node_capabilities, leaf_node_extensions) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_self_update(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, addHeapObject(leaf_node_capabilities), addHeapObject(leaf_node_extensions));
    }
    exports.wire__crate__api__engine__MlsEngine_propose_self_update = wire__crate__api__engine__MlsEngine_propose_self_update;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint32Array} member_indices
     */
    function wire__crate__api__engine__MlsEngine_remove_members(port_, that, group_id_bytes, signer_bytes, member_indices) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray32ToWasm0(member_indices, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_remove_members(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2);
    }
    exports.wire__crate__api__engine__MlsEngine_remove_members = wire__crate__api__engine__MlsEngine_remove_members;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} proposal_ref_bytes
     */
    function wire__crate__api__engine__MlsEngine_remove_pending_proposal(port_, that, group_id_bytes, proposal_ref_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(proposal_ref_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_remove_pending_proposal(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_remove_pending_proposal = wire__crate__api__engine__MlsEngine_remove_pending_proposal;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__engine__MlsEngine_schema_version(that) {
        const ret = wasm.wire__crate__api__engine__MlsEngine_schema_version(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__engine__MlsEngine_schema_version = wire__crate__api__engine__MlsEngine_schema_version;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_self_update(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_self_update(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_self_update = wire__crate__api__engine__MlsEngine_self_update;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} old_signer_bytes
     * @param {Uint8Array} new_signer_bytes
     * @param {Uint8Array} new_credential_identity
     * @param {Uint8Array} new_signer_public_key
     * @param {Uint8Array | null} [new_credential_bytes]
     */
    function wire__crate__api__engine__MlsEngine_self_update_with_new_signer(port_, that, group_id_bytes, old_signer_bytes, new_signer_bytes, new_credential_identity, new_signer_public_key, new_credential_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(old_signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(new_signer_bytes, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(new_credential_identity, wasm.__wbindgen_export);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(new_signer_public_key, wasm.__wbindgen_export);
        const len4 = WASM_VECTOR_LEN;
        var ptr5 = isLikeNone(new_credential_bytes) ? 0 : passArray8ToWasm0(new_credential_bytes, wasm.__wbindgen_export);
        var len5 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_self_update_with_new_signer(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5);
    }
    exports.wire__crate__api__engine__MlsEngine_self_update_with_new_signer = wire__crate__api__engine__MlsEngine_self_update_with_new_signer;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {any} config
     */
    function wire__crate__api__engine__MlsEngine_set_configuration(port_, that, group_id_bytes, config) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_set_configuration(addHeapObject(port_), addHeapObject(that), ptr0, len0, addHeapObject(config));
    }
    exports.wire__crate__api__engine__MlsEngine_set_configuration = wire__crate__api__engine__MlsEngine_set_configuration;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {Uint32Array} remove_indices
     * @param {any} add_key_packages_bytes
     */
    function wire__crate__api__engine__MlsEngine_swap_members(port_, that, group_id_bytes, signer_bytes, remove_indices, add_key_packages_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray32ToWasm0(remove_indices, wasm.__wbindgen_export);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_swap_members(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, ptr2, len2, addHeapObject(add_key_packages_bytes));
    }
    exports.wire__crate__api__engine__MlsEngine_swap_members = wire__crate__api__engine__MlsEngine_swap_members;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     * @param {any} extensions
     */
    function wire__crate__api__engine__MlsEngine_update_group_context_extensions(port_, that, group_id_bytes, signer_bytes, extensions) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_update_group_context_extensions(addHeapObject(port_), addHeapObject(that), ptr0, len0, ptr1, len1, addHeapObject(extensions));
    }
    exports.wire__crate__api__engine__MlsEngine_update_group_context_extensions = wire__crate__api__engine__MlsEngine_update_group_context_extensions;

    /**
     * @param {Uint8Array} message_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__mls_message_content_type(message_bytes) {
        const ptr0 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__mls_message_content_type(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__engine__mls_message_content_type = wire__crate__api__engine__mls_message_content_type;

    /**
     * @param {Uint8Array} message_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__mls_message_extract_epoch(message_bytes) {
        const ptr0 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__mls_message_extract_epoch(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__engine__mls_message_extract_epoch = wire__crate__api__engine__mls_message_extract_epoch;

    /**
     * @param {Uint8Array} message_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__mls_message_extract_group_id(message_bytes) {
        const ptr0 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__mls_message_extract_group_id(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__engine__mls_message_extract_group_id = wire__crate__api__engine__mls_message_extract_group_id;

    /**
     * @param {string} _library_path
     * @returns {any}
     */
    function wire__crate__api__init__init_openmls(_library_path) {
        const ptr0 = passStringToWasm0(_library_path, wasm.__wbindgen_export, wasm.__wbindgen_export2);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__init__init_openmls(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__init__init_openmls = wire__crate__api__init__init_openmls;

    /**
     * @returns {any}
     */
    function wire__crate__api__init__is_openmls_initialized() {
        const ret = wasm.wire__crate__api__init__is_openmls_initialized();
        return takeObject(ret);
    }
    exports.wire__crate__api__init__is_openmls_initialized = wire__crate__api__init__is_openmls_initialized;

    /**
     * @param {Uint8Array} bytes
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public(bytes) {
        const ptr0 = passArray8ToWasm0(bytes, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public(ptr0, len0);
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public = wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public;

    /**
     * @param {number} ciphersuite
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_from_raw(ciphersuite, private_key, public_key) {
        const ptr0 = passArray8ToWasm0(private_key, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(public_key, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_from_raw(ciphersuite, ptr0, len0, ptr1, len1);
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_from_raw = wire__crate__api__keys__MlsSignatureKeyPair_from_raw;

    /**
     * @param {number} ciphersuite
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_generate(ciphersuite) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_generate(ciphersuite);
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_generate = wire__crate__api__keys__MlsSignatureKeyPair_generate;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_private_key(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_private_key(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_private_key = wire__crate__api__keys__MlsSignatureKeyPair_private_key;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_public_key(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_public_key(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_public_key = wire__crate__api__keys__MlsSignatureKeyPair_public_key;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_serialize(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_serialize(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_serialize = wire__crate__api__keys__MlsSignatureKeyPair_serialize;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme(addHeapObject(that));
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme = wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme;

    /**
     * @param {number} ciphersuite
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @returns {any}
     */
    function wire__crate__api__keys__serialize_signer(ciphersuite, private_key, public_key) {
        const ptr0 = passArray8ToWasm0(private_key, wasm.__wbindgen_export);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(public_key, wasm.__wbindgen_export);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__keys__serialize_signer(ciphersuite, ptr0, len0, ptr1, len1);
        return takeObject(ret);
    }
    exports.wire__crate__api__keys__serialize_signer = wire__crate__api__keys__serialize_signer;

    /**
     * @returns {any}
     */
    function wire__crate__api__types__supported_ciphersuites() {
        const ret = wasm.wire__crate__api__types__supported_ciphersuites();
        return takeObject(ret);
    }
    exports.wire__crate__api__types__supported_ciphersuites = wire__crate__api__types__supported_ciphersuites;

    function __wbg_get_imports() {
        const import0 = {
            __proto__: null,
            __wbg_Deno_0d853884e73838c9: function(arg0) {
                const ret = getObject(arg0).Deno;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_Number_04624de7d0e8332d: function(arg0) {
                const ret = Number(getObject(arg0));
                return ret;
            },
            __wbg___wbg_test_output_writeln_3002c52094d744d1: function(arg0) {
                __wbg_test_output_writeln(takeObject(arg0));
            },
            __wbg___wbgtest_og_console_log_81bdd3488fd1939c: function(arg0, arg1) {
                __wbgtest_og_console_log(getStringFromWasm0(arg0, arg1));
            },
            __wbg___wbindgen_bigint_get_as_i64_8fcf4ce7f1ca72a2: function(arg0, arg1) {
                const v = getObject(arg1);
                const ret = typeof(v) === 'bigint' ? v : undefined;
                getDataViewMemory0().setBigInt64(arg0 + 8 * 1, isLikeNone(ret) ? BigInt(0) : ret, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
            },
            __wbg___wbindgen_debug_string_0bc8482c6e3508ae: function(arg0, arg1) {
                const ret = debugString(getObject(arg1));
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbindgen_is_falsy_e623e5b815413d00: function(arg0) {
                const ret = !getObject(arg0);
                return ret;
            },
            __wbg___wbindgen_is_function_0095a73b8b156f76: function(arg0) {
                const ret = typeof(getObject(arg0)) === 'function';
                return ret;
            },
            __wbg___wbindgen_is_null_ac34f5003991759a: function(arg0) {
                const ret = getObject(arg0) === null;
                return ret;
            },
            __wbg___wbindgen_is_object_5ae8e5880f2c1fbd: function(arg0) {
                const val = getObject(arg0);
                const ret = typeof(val) === 'object' && val !== null;
                return ret;
            },
            __wbg___wbindgen_is_string_cd444516edc5b180: function(arg0) {
                const ret = typeof(getObject(arg0)) === 'string';
                return ret;
            },
            __wbg___wbindgen_is_undefined_9e4d92534c42d778: function(arg0) {
                const ret = getObject(arg0) === undefined;
                return ret;
            },
            __wbg___wbindgen_jsval_eq_11888390b0186270: function(arg0, arg1) {
                const ret = getObject(arg0) === getObject(arg1);
                return ret;
            },
            __wbg___wbindgen_memory_bd1fbcf21fbef3c8: function() {
                const ret = wasm.memory;
                return addHeapObject(ret);
            },
            __wbg___wbindgen_module_f6b8052d79c1cc16: function() {
                const ret = wasmModule;
                return addHeapObject(ret);
            },
            __wbg___wbindgen_number_get_8ff4255516ccad3e: function(arg0, arg1) {
                const obj = getObject(arg1);
                const ret = typeof(obj) === 'number' ? obj : undefined;
                getDataViewMemory0().setFloat64(arg0 + 8 * 1, isLikeNone(ret) ? 0 : ret, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
            },
            __wbg___wbindgen_string_get_72fb696202c56729: function(arg0, arg1) {
                const obj = getObject(arg1);
                const ret = typeof(obj) === 'string' ? obj : undefined;
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbindgen_throw_be289d5034ed271b: function(arg0, arg1) {
                throw new Error(getStringFromWasm0(arg0, arg1));
            },
            __wbg__wbg_cb_unref_d9b87ff7982e3b21: function(arg0) {
                getObject(arg0)._wbg_cb_unref();
            },
            __wbg_call_389efe28435a9388: function() { return handleError(function (arg0, arg1) {
                const ret = getObject(arg0).call(getObject(arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_call_4708e0c13bdc8e95: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = getObject(arg0).call(getObject(arg1), getObject(arg2));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_close_53683f4809368fc7: function(arg0) {
                getObject(arg0).close();
            },
            __wbg_commit_a6c7bc9e0c454a94: function() { return handleError(function (arg0) {
                getObject(arg0).commit();
            }, arguments); },
            __wbg_constructor_0075742d4adcfb5d: function(arg0) {
                const ret = getObject(arg0).constructor;
                return addHeapObject(ret);
            },
            __wbg_createObjectStore_f75f59d55a549868: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = getObject(arg0).createObjectStore(getStringFromWasm0(arg1, arg2), getObject(arg3));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_createObjectURL_918185db6a10a0c8: function() { return handleError(function (arg0, arg1) {
                const ret = URL.createObjectURL(getObject(arg1));
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            }, arguments); },
            __wbg_crypto_86f2631e91b51511: function(arg0) {
                const ret = getObject(arg0).crypto;
                return addHeapObject(ret);
            },
            __wbg_crypto_e4b88bdecc3312df: function() { return handleError(function (arg0) {
                const ret = getObject(arg0).crypto;
                return addHeapObject(ret);
            }, arguments); },
            __wbg_data_5330da50312d0bc1: function(arg0) {
                const ret = getObject(arg0).data;
                return addHeapObject(ret);
            },
            __wbg_decrypt_b4c0fda2d8840faa: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = getObject(arg0).decrypt(getObject(arg1), getObject(arg2), getObject(arg3));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_delete_d6d7f750bd9ed2cd: function() { return handleError(function (arg0, arg1) {
                const ret = getObject(arg0).delete(getObject(arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_encrypt_7a17a72b7fe3130c: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = getObject(arg0).encrypt(getObject(arg1), getObject(arg2), getObject(arg3));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_error_076d4beefd7cfd14: function(arg0, arg1) {
                console.error(getStringFromWasm0(arg0, arg1));
            },
            __wbg_error_6afb95c784775817: function() { return handleError(function (arg0) {
                const ret = getObject(arg0).error;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            }, arguments); },
            __wbg_error_7534b8e9a36f1ab4: function(arg0, arg1) {
                let deferred0_0;
                let deferred0_1;
                try {
                    deferred0_0 = arg0;
                    deferred0_1 = arg1;
                    console.error(getStringFromWasm0(arg0, arg1));
                } finally {
                    wasm.__wbindgen_export4(deferred0_0, deferred0_1, 1);
                }
            },
            __wbg_error_ba0ecc4c5be76ff7: function(arg0, arg1) {
                console.error(getStringFromWasm0(arg0, arg1));
            },
            __wbg_error_bf9fa99d609a0ce7: function(arg0) {
                const ret = getObject(arg0).error;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_eval_3f0b9f0cbaf45a34: function() { return handleError(function (arg0, arg1) {
                const ret = eval(getStringFromWasm0(arg0, arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_getAllKeys_c69c2b19589fffe6: function() { return handleError(function (arg0) {
                const ret = getObject(arg0).getAllKeys();
                return addHeapObject(ret);
            }, arguments); },
            __wbg_getElementById_6fe6fa2cb1c02939: function(arg0, arg1, arg2) {
                const ret = getObject(arg0).getElementById(getStringFromWasm0(arg1, arg2));
                return addHeapObject(ret);
            },
            __wbg_getRandomValues_1c61fac11405ffdc: function() { return handleError(function (arg0, arg1) {
                globalThis.crypto.getRandomValues(getArrayU8FromWasm0(arg0, arg1));
            }, arguments); },
            __wbg_getRandomValues_b3f15fcbfabb0f8b: function() { return handleError(function (arg0, arg1) {
                getObject(arg0).getRandomValues(getObject(arg1));
            }, arguments); },
            __wbg_get_5e856edb32ac1289: function() { return handleError(function (arg0, arg1) {
                const ret = getObject(arg0).get(getObject(arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_get_626204a85e34f823: function(arg0, arg1, arg2) {
                const ret = getObject(arg1)[arg2 >>> 0];
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_get_9b94d73e6221f75c: function(arg0, arg1) {
                const ret = getObject(arg0)[arg1 >>> 0];
                return addHeapObject(ret);
            },
            __wbg_get_b3ed3ad4be2bc8ac: function() { return handleError(function (arg0, arg1) {
                const ret = Reflect.get(getObject(arg0), getObject(arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_importKey_661f658f27d8a5b3: function() { return handleError(function (arg0, arg1, arg2, arg3, arg4, arg5, arg6) {
                const ret = getObject(arg0).importKey(getStringFromWasm0(arg1, arg2), getObject(arg3), getObject(arg4), arg5 !== 0, getObject(arg6));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_instanceof_BroadcastChannel_cb5d139378d0f206: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof BroadcastChannel;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_CryptoKey_4b17f64db095a0a2: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof CryptoKey;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_ErrorEvent_cd1bf636fceb3180: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof ErrorEvent;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbDatabase_8d723b3ff4761c2d: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof IDBDatabase;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbFactory_39d4fb6425cae0a6: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof IDBFactory;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbOpenDbRequest_e476921a744b955b: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof IDBOpenDBRequest;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbRequest_6388508cc77f8da0: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof IDBRequest;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbTransaction_ec5dc92e602db81d: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof IDBTransaction;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_MessageEvent_1a6960e6b15377ad: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof MessageEvent;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_Window_ed49b2db8df90359: function(arg0) {
                let result;
                try {
                    result = getObject(arg0) instanceof Window;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_isArray_d314bb98fcf08331: function(arg0) {
                const ret = Array.isArray(getObject(arg0));
                return ret;
            },
            __wbg_length_1e8b0a6e52c08b9a: function(arg0) {
                const ret = getObject(arg0).length;
                return ret;
            },
            __wbg_length_32ed9a279acd054c: function(arg0) {
                const ret = getObject(arg0).length;
                return ret;
            },
            __wbg_length_35a7bace40f36eac: function(arg0) {
                const ret = getObject(arg0).length;
                return ret;
            },
            __wbg_length_4c6eb4059a3635c9: function(arg0) {
                const ret = getObject(arg0).length;
                return ret;
            },
            __wbg_length_8ce069301528a78d: function(arg0) {
                const ret = getObject(arg0).length;
                return ret;
            },
            __wbg_log_dac59df46f28c346: function(arg0, arg1) {
                console.log(getStringFromWasm0(arg0, arg1));
            },
            __wbg_message_6de0e1db93388eee: function(arg0, arg1) {
                const ret = getObject(arg1).message;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_message_9ddc4b9a62a7c379: function(arg0) {
                const ret = getObject(arg0).message;
                return addHeapObject(ret);
            },
            __wbg_msCrypto_d562bbe83e0d4b91: function(arg0) {
                const ret = getObject(arg0).msCrypto;
                return addHeapObject(ret);
            },
            __wbg_name_37226f1b7db3540e: function(arg0, arg1) {
                const ret = getObject(arg1).name;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_name_446e25ef2cfdab5a: function(arg0) {
                const ret = getObject(arg0).name;
                return addHeapObject(ret);
            },
            __wbg_name_919ac24b80128f9f: function(arg0, arg1) {
                const ret = getObject(arg1).name;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_new_361308b2356cecd0: function() {
                const ret = new Object();
                return addHeapObject(ret);
            },
            __wbg_new_3eb36ae241fe6f44: function() {
                const ret = new Array();
                return addHeapObject(ret);
            },
            __wbg_new_4f8f3c123e474358: function() { return handleError(function (arg0, arg1) {
                const ret = new Worker(getStringFromWasm0(arg0, arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_new_8a6f238a6ece86ea: function() {
                const ret = new Error();
                return addHeapObject(ret);
            },
            __wbg_new_afb8dbb951819ab7: function() { return handleError(function (arg0, arg1) {
                const ret = new BroadcastChannel(getStringFromWasm0(arg0, arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_new_b5d9e2fb389fef91: function(arg0, arg1) {
                try {
                    var state0 = {a: arg0, b: arg1};
                    var cb0 = (arg0, arg1) => {
                        const a = state0.a;
                        state0.a = 0;
                        try {
                            return __wasm_bindgen_func_elem_1467(a, state0.b, arg0, arg1);
                        } finally {
                            state0.a = a;
                        }
                    };
                    const ret = new Promise(cb0);
                    return addHeapObject(ret);
                } finally {
                    state0.a = state0.b = 0;
                }
            },
            __wbg_new_dd2b680c8bf6ae29: function(arg0) {
                const ret = new Uint8Array(getObject(arg0));
                return addHeapObject(ret);
            },
            __wbg_new_f0796def86e99471: function() {
                const ret = new Error();
                return addHeapObject(ret);
            },
            __wbg_new_from_slice_19d21922ff3c0ae6: function(arg0, arg1) {
                const ret = new Uint32Array(getArrayU32FromWasm0(arg0, arg1));
                return addHeapObject(ret);
            },
            __wbg_new_from_slice_980b409db81dc3eb: function(arg0, arg1) {
                const ret = new Uint16Array(getArrayU16FromWasm0(arg0, arg1));
                return addHeapObject(ret);
            },
            __wbg_new_from_slice_a3d2629dc1826784: function(arg0, arg1) {
                const ret = new Uint8Array(getArrayU8FromWasm0(arg0, arg1));
                return addHeapObject(ret);
            },
            __wbg_new_no_args_1c7c842f08d00ebb: function(arg0, arg1) {
                const ret = new Function(getStringFromWasm0(arg0, arg1));
                return addHeapObject(ret);
            },
            __wbg_new_with_blob_sequence_and_options_49f0dade7a77cd73: function() { return handleError(function (arg0, arg1) {
                const ret = new Blob(getObject(arg0), getObject(arg1));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_new_with_length_a2c39cbe88fd8ff1: function(arg0) {
                const ret = new Uint8Array(arg0 >>> 0);
                return addHeapObject(ret);
            },
            __wbg_node_e1f24f89a7336c2e: function(arg0) {
                const ret = getObject(arg0).node;
                return addHeapObject(ret);
            },
            __wbg_now_706dbbd146774f0e: function(arg0) {
                const ret = getObject(arg0).now();
                return ret;
            },
            __wbg_now_a3af9a2f4bbaa4d1: function() {
                const ret = Date.now();
                return ret;
            },
            __wbg_objectStoreNames_d2c5d2377420ad78: function(arg0) {
                const ret = getObject(arg0).objectStoreNames;
                return addHeapObject(ret);
            },
            __wbg_objectStore_d56e603390dcc165: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = getObject(arg0).objectStore(getStringFromWasm0(arg1, arg2));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_oldVersion_97e5f91fffb21425: function(arg0) {
                const ret = getObject(arg0).oldVersion;
                return ret;
            },
            __wbg_open_82db86fd5b087109: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = getObject(arg0).open(getStringFromWasm0(arg1, arg2), arg3 >>> 0);
                return addHeapObject(ret);
            }, arguments); },
            __wbg_performance_2767f30f4a69c748: function(arg0) {
                const ret = getObject(arg0).performance;
                return addHeapObject(ret);
            },
            __wbg_postMessage_2041f4e90af61318: function() { return handleError(function (arg0, arg1) {
                getObject(arg0).postMessage(getObject(arg1));
            }, arguments); },
            __wbg_postMessage_33814d4dc32c2dcf: function() { return handleError(function (arg0, arg1) {
                getObject(arg0).postMessage(getObject(arg1));
            }, arguments); },
            __wbg_postMessage_771ef3293a28bbac: function() { return handleError(function (arg0, arg1) {
                getObject(arg0).postMessage(getObject(arg1));
            }, arguments); },
            __wbg_process_3975fd6c72f520aa: function(arg0) {
                const ret = getObject(arg0).process;
                return addHeapObject(ret);
            },
            __wbg_prototypesetcall_2adb484744144f7f: function(arg0, arg1, arg2) {
                Uint16Array.prototype.set.call(getArrayU16FromWasm0(arg0, arg1), getObject(arg2));
            },
            __wbg_prototypesetcall_4846d4aa386c936f: function(arg0, arg1, arg2) {
                Uint32Array.prototype.set.call(getArrayU32FromWasm0(arg0, arg1), getObject(arg2));
            },
            __wbg_prototypesetcall_bdcdcc5842e4d77d: function(arg0, arg1, arg2) {
                Uint8Array.prototype.set.call(getArrayU8FromWasm0(arg0, arg1), getObject(arg2));
            },
            __wbg_push_8ffdcb2063340ba5: function(arg0, arg1) {
                const ret = getObject(arg0).push(getObject(arg1));
                return ret;
            },
            __wbg_put_b34701a38436f20a: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = getObject(arg0).put(getObject(arg1), getObject(arg2));
                return addHeapObject(ret);
            }, arguments); },
            __wbg_queueMicrotask_0aa0a927f78f5d98: function(arg0) {
                const ret = getObject(arg0).queueMicrotask;
                return addHeapObject(ret);
            },
            __wbg_queueMicrotask_5bb536982f78a56f: function(arg0) {
                queueMicrotask(getObject(arg0));
            },
            __wbg_randomFillSync_f8c153b79f285817: function() { return handleError(function (arg0, arg1) {
                getObject(arg0).randomFillSync(takeObject(arg1));
            }, arguments); },
            __wbg_random_912284dbf636f269: function() {
                const ret = Math.random();
                return ret;
            },
            __wbg_require_b74f47fc2d022fd6: function() { return handleError(function () {
                const ret = module.require;
                return addHeapObject(ret);
            }, arguments); },
            __wbg_resolve_002c4b7d9d8f6b64: function(arg0) {
                const ret = Promise.resolve(getObject(arg0));
                return addHeapObject(ret);
            },
            __wbg_result_233b2d68aae87a05: function() { return handleError(function (arg0) {
                const ret = getObject(arg0).result;
                return addHeapObject(ret);
            }, arguments); },
            __wbg_self_cfdfc96e68c3e345: function(arg0) {
                const ret = getObject(arg0).self;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_set_6cb8631f80447a67: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = Reflect.set(getObject(arg0), getObject(arg1), getObject(arg2));
                return ret;
            }, arguments); },
            __wbg_set_iv_65a7d6a9594a4559: function(arg0, arg1) {
                getObject(arg0).iv = getObject(arg1);
            },
            __wbg_set_name_3a11e4962e0fac9d: function(arg0, arg1, arg2) {
                getObject(arg0).name = getStringFromWasm0(arg1, arg2);
            },
            __wbg_set_onabort_5b85743a64489257: function(arg0, arg1) {
                getObject(arg0).onabort = getObject(arg1);
            },
            __wbg_set_oncomplete_76d4a772a6c8cab6: function(arg0, arg1) {
                getObject(arg0).oncomplete = getObject(arg1);
            },
            __wbg_set_onerror_73f3137061c9c32e: function(arg0, arg1) {
                getObject(arg0).onerror = getObject(arg1);
            },
            __wbg_set_onerror_d0db7c6491b9399d: function(arg0, arg1) {
                getObject(arg0).onerror = getObject(arg1);
            },
            __wbg_set_onerror_dc0e606b09e1792f: function(arg0, arg1) {
                getObject(arg0).onerror = getObject(arg1);
            },
            __wbg_set_onmessage_6ed41050e4a5cee2: function(arg0, arg1) {
                getObject(arg0).onmessage = getObject(arg1);
            },
            __wbg_set_onsuccess_0edec1acb4124784: function(arg0, arg1) {
                getObject(arg0).onsuccess = getObject(arg1);
            },
            __wbg_set_onupgradeneeded_c887b74722b6ce77: function(arg0, arg1) {
                getObject(arg0).onupgradeneeded = getObject(arg1);
            },
            __wbg_set_text_content_eb601b93a64fea40: function(arg0, arg1, arg2) {
                getObject(arg0).textContent = getStringFromWasm0(arg1, arg2);
            },
            __wbg_set_type_148de20768639245: function(arg0, arg1, arg2) {
                getObject(arg0).type = getStringFromWasm0(arg1, arg2);
            },
            __wbg_stack_0ed75d68575b0f3c: function(arg0, arg1) {
                const ret = getObject(arg1).stack;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_stack_50b68ee6ee330278: function(arg0) {
                const ret = getObject(arg0).stack;
                return addHeapObject(ret);
            },
            __wbg_stack_8b207ade94c30c09: function(arg0, arg1) {
                const ret = getObject(arg1).stack;
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_stack_bc8a0cd36a8aaa5e: function(arg0) {
                const ret = getObject(arg0).stack;
                return addHeapObject(ret);
            },
            __wbg_stack_e11a2e83d033ed2f: function(arg0, arg1) {
                const ret = getObject(arg1).stack;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_static_accessor_DOCUMENT_a8bee90773ed9f03: function() {
                const ret = document;
                return addHeapObject(ret);
            },
            __wbg_static_accessor_GLOBAL_12837167ad935116: function() {
                const ret = typeof global === 'undefined' ? null : global;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_static_accessor_GLOBAL_THIS_e628e89ab3b1c95f: function() {
                const ret = typeof globalThis === 'undefined' ? null : globalThis;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_static_accessor_SELF_a621d3dfbb60d0ce: function() {
                const ret = typeof self === 'undefined' ? null : self;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_static_accessor_WINDOW_f8727f0cf888e0bd: function() {
                const ret = typeof window === 'undefined' ? null : window;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_subarray_a96e1fef17ed23cb: function(arg0, arg1, arg2) {
                const ret = getObject(arg0).subarray(arg1 >>> 0, arg2 >>> 0);
                return addHeapObject(ret);
            },
            __wbg_subtle_9d4bb4e872f71546: function(arg0) {
                const ret = getObject(arg0).subtle;
                return addHeapObject(ret);
            },
            __wbg_target_521be630ab05b11e: function(arg0) {
                const ret = getObject(arg0).target;
                return isLikeNone(ret) ? 0 : addHeapObject(ret);
            },
            __wbg_text_content_50199b46165a6fba: function(arg0, arg1) {
                const ret = getObject(arg1).textContent;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_then_0d9fe2c7b1857d32: function(arg0, arg1, arg2) {
                const ret = getObject(arg0).then(getObject(arg1), getObject(arg2));
                return addHeapObject(ret);
            },
            __wbg_then_b9e7b3b5f1a9e1b5: function(arg0, arg1) {
                const ret = getObject(arg0).then(getObject(arg1));
                return addHeapObject(ret);
            },
            __wbg_toString_1f277cfdc1753469: function() { return handleError(function (arg0, arg1) {
                const ret = getObject(arg1).toString();
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_export, wasm.__wbindgen_export2);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            }, arguments); },
            __wbg_toString_964ff7fe6eca8362: function(arg0) {
                const ret = getObject(arg0).toString();
                return addHeapObject(ret);
            },
            __wbg_transaction_c407989db8e62119: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = getObject(arg0).transaction(getObject(arg1), __wbindgen_enum_IdbTransactionMode[arg2]);
                return addHeapObject(ret);
            }, arguments); },
            __wbg_versions_4e31226f5e8dc909: function(arg0) {
                const ret = getObject(arg0).versions;
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000001: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { dtor_idx: 42, function: Function { arguments: [Externref], shim_idx: 43, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm.__wasm_bindgen_func_elem_851, __wasm_bindgen_func_elem_852);
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000002: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { dtor_idx: 42, function: Function { arguments: [NamedExternref("Event")], shim_idx: 43, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm.__wasm_bindgen_func_elem_851, __wasm_bindgen_func_elem_852);
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000003: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { dtor_idx: 42, function: Function { arguments: [NamedExternref("IDBVersionChangeEvent")], shim_idx: 43, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm.__wasm_bindgen_func_elem_851, __wasm_bindgen_func_elem_852);
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000004: function(arg0) {
                // Cast intrinsic for `F64 -> Externref`.
                const ret = arg0;
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000005: function(arg0, arg1) {
                // Cast intrinsic for `Ref(Slice(U8)) -> NamedExternref("Uint8Array")`.
                const ret = getArrayU8FromWasm0(arg0, arg1);
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000006: function(arg0, arg1) {
                // Cast intrinsic for `Ref(String) -> Externref`.
                const ret = getStringFromWasm0(arg0, arg1);
                return addHeapObject(ret);
            },
            __wbindgen_cast_0000000000000007: function(arg0) {
                // Cast intrinsic for `U64 -> Externref`.
                const ret = BigInt.asUintN(64, arg0);
                return addHeapObject(ret);
            },
            __wbindgen_object_clone_ref: function(arg0) {
                const ret = getObject(arg0);
                return addHeapObject(ret);
            },
            __wbindgen_object_drop_ref: function(arg0) {
                takeObject(arg0);
            },
        };
        return {
            __proto__: null,
            "./openmls_frb_bg.js": import0,
        };
    }

    function __wasm_bindgen_func_elem_852(arg0, arg1, arg2) {
        wasm.__wasm_bindgen_func_elem_852(arg0, arg1, addHeapObject(arg2));
    }

    function __wasm_bindgen_func_elem_1467(arg0, arg1, arg2, arg3) {
        wasm.__wasm_bindgen_func_elem_1467(arg0, arg1, addHeapObject(arg2), addHeapObject(arg3));
    }


    const __wbindgen_enum_IdbTransactionMode = ["readonly", "readwrite", "versionchange", "readwriteflush", "cleanup"];
    const WasmBindgenTestContextFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_wasmbindgentestcontext_free(ptr >>> 0, 1));
    const WorkerPoolFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_workerpool_free(ptr >>> 0, 1));

    function addHeapObject(obj) {
        if (heap_next === heap.length) heap.push(heap.length + 1);
        const idx = heap_next;
        heap_next = heap[idx];

        heap[idx] = obj;
        return idx;
    }

    function addBorrowedObject(obj) {
        if (stack_pointer == 1) throw new Error('out of js stack');
        heap[--stack_pointer] = obj;
        return stack_pointer;
    }

    const CLOSURE_DTORS = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(state => state.dtor(state.a, state.b));

    function debugString(val) {
        // primitive types
        const type = typeof val;
        if (type == 'number' || type == 'boolean' || val == null) {
            return  `${val}`;
        }
        if (type == 'string') {
            return `"${val}"`;
        }
        if (type == 'symbol') {
            const description = val.description;
            if (description == null) {
                return 'Symbol';
            } else {
                return `Symbol(${description})`;
            }
        }
        if (type == 'function') {
            const name = val.name;
            if (typeof name == 'string' && name.length > 0) {
                return `Function(${name})`;
            } else {
                return 'Function';
            }
        }
        // objects
        if (Array.isArray(val)) {
            const length = val.length;
            let debug = '[';
            if (length > 0) {
                debug += debugString(val[0]);
            }
            for(let i = 1; i < length; i++) {
                debug += ', ' + debugString(val[i]);
            }
            debug += ']';
            return debug;
        }
        // Test for built-in
        const builtInMatches = /\[object ([^\]]+)\]/.exec(toString.call(val));
        let className;
        if (builtInMatches && builtInMatches.length > 1) {
            className = builtInMatches[1];
        } else {
            // Failed to match the standard '[object ClassName]'
            return toString.call(val);
        }
        if (className == 'Object') {
            // we're a user defined class or Object
            // JSON.stringify avoids problems with cycles, and is generally much
            // easier than looping through ownProperties of `val`.
            try {
                return 'Object(' + JSON.stringify(val) + ')';
            } catch (_) {
                return 'Object';
            }
        }
        // errors
        if (val instanceof Error) {
            return `${val.name}: ${val.message}\n${val.stack}`;
        }
        // TODO we could test for more things here, like `Set`s and `Map`s.
        return className;
    }

    function dropObject(idx) {
        if (idx < 132) return;
        heap[idx] = heap_next;
        heap_next = idx;
    }

    function getArrayU16FromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return getUint16ArrayMemory0().subarray(ptr / 2, ptr / 2 + len);
    }

    function getArrayU32FromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return getUint32ArrayMemory0().subarray(ptr / 4, ptr / 4 + len);
    }

    function getArrayU8FromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return getUint8ArrayMemory0().subarray(ptr / 1, ptr / 1 + len);
    }

    let cachedDataViewMemory0 = null;
    function getDataViewMemory0() {
        if (cachedDataViewMemory0 === null || cachedDataViewMemory0.buffer.detached === true || (cachedDataViewMemory0.buffer.detached === undefined && cachedDataViewMemory0.buffer !== wasm.memory.buffer)) {
            cachedDataViewMemory0 = new DataView(wasm.memory.buffer);
        }
        return cachedDataViewMemory0;
    }

    function getStringFromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return decodeText(ptr, len);
    }

    let cachedUint16ArrayMemory0 = null;
    function getUint16ArrayMemory0() {
        if (cachedUint16ArrayMemory0 === null || cachedUint16ArrayMemory0.byteLength === 0) {
            cachedUint16ArrayMemory0 = new Uint16Array(wasm.memory.buffer);
        }
        return cachedUint16ArrayMemory0;
    }

    let cachedUint32ArrayMemory0 = null;
    function getUint32ArrayMemory0() {
        if (cachedUint32ArrayMemory0 === null || cachedUint32ArrayMemory0.byteLength === 0) {
            cachedUint32ArrayMemory0 = new Uint32Array(wasm.memory.buffer);
        }
        return cachedUint32ArrayMemory0;
    }

    let cachedUint8ArrayMemory0 = null;
    function getUint8ArrayMemory0() {
        if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
            cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
        }
        return cachedUint8ArrayMemory0;
    }

    function getObject(idx) { return heap[idx]; }

    function handleError(f, args) {
        try {
            return f.apply(this, args);
        } catch (e) {
            wasm.__wbindgen_export3(addHeapObject(e));
        }
    }

    let heap = new Array(128).fill(undefined);
    heap.push(undefined, null, true, false);

    let heap_next = heap.length;

    function isLikeNone(x) {
        return x === undefined || x === null;
    }

    function makeMutClosure(arg0, arg1, dtor, f) {
        const state = { a: arg0, b: arg1, cnt: 1, dtor };
        const real = (...args) => {

            // First up with a closure we increment the internal reference
            // count. This ensures that the Rust closure environment won't
            // be deallocated while we're invoking it.
            state.cnt++;
            const a = state.a;
            state.a = 0;
            try {
                return f(a, state.b, ...args);
            } finally {
                state.a = a;
                real._wbg_cb_unref();
            }
        };
        real._wbg_cb_unref = () => {
            if (--state.cnt === 0) {
                state.dtor(state.a, state.b);
                state.a = 0;
                CLOSURE_DTORS.unregister(state);
            }
        };
        CLOSURE_DTORS.register(real, state, state);
        return real;
    }

    function passArray32ToWasm0(arg, malloc) {
        const ptr = malloc(arg.length * 4, 4) >>> 0;
        getUint32ArrayMemory0().set(arg, ptr / 4);
        WASM_VECTOR_LEN = arg.length;
        return ptr;
    }

    function passArray8ToWasm0(arg, malloc) {
        const ptr = malloc(arg.length * 1, 1) >>> 0;
        getUint8ArrayMemory0().set(arg, ptr / 1);
        WASM_VECTOR_LEN = arg.length;
        return ptr;
    }

    function passArrayJsValueToWasm0(array, malloc) {
        const ptr = malloc(array.length * 4, 4) >>> 0;
        const mem = getDataViewMemory0();
        for (let i = 0; i < array.length; i++) {
            mem.setUint32(ptr + 4 * i, addHeapObject(array[i]), true);
        }
        WASM_VECTOR_LEN = array.length;
        return ptr;
    }

    function passStringToWasm0(arg, malloc, realloc) {
        if (realloc === undefined) {
            const buf = cachedTextEncoder.encode(arg);
            const ptr = malloc(buf.length, 1) >>> 0;
            getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
            WASM_VECTOR_LEN = buf.length;
            return ptr;
        }

        let len = arg.length;
        let ptr = malloc(len, 1) >>> 0;

        const mem = getUint8ArrayMemory0();

        let offset = 0;

        for (; offset < len; offset++) {
            const code = arg.charCodeAt(offset);
            if (code > 0x7F) break;
            mem[ptr + offset] = code;
        }
        if (offset !== len) {
            if (offset !== 0) {
                arg = arg.slice(offset);
            }
            ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
            const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
            const ret = cachedTextEncoder.encodeInto(arg, view);

            offset += ret.written;
            ptr = realloc(ptr, len, offset, 1) >>> 0;
        }

        WASM_VECTOR_LEN = offset;
        return ptr;
    }

    let stack_pointer = 128;

    function takeObject(idx) {
        const ret = getObject(idx);
        dropObject(idx);
        return ret;
    }

    let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
    cachedTextDecoder.decode();
    function decodeText(ptr, len) {
        return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
    }

    const cachedTextEncoder = new TextEncoder();

    if (!('encodeInto' in cachedTextEncoder)) {
        cachedTextEncoder.encodeInto = function (arg, view) {
            const buf = cachedTextEncoder.encode(arg);
            view.set(buf);
            return {
                read: arg.length,
                written: buf.length
            };
        };
    }

    let WASM_VECTOR_LEN = 0;

    let wasmModule, wasm;
    function __wbg_finalize_init(instance, module) {
        wasm = instance.exports;
        wasmModule = module;
        cachedDataViewMemory0 = null;
        cachedUint16ArrayMemory0 = null;
        cachedUint32ArrayMemory0 = null;
        cachedUint8ArrayMemory0 = null;
        wasm.__wbindgen_start();
        return wasm;
    }

    async function __wbg_load(module, imports) {
        if (typeof Response === 'function' && module instanceof Response) {
            if (typeof WebAssembly.instantiateStreaming === 'function') {
                try {
                    return await WebAssembly.instantiateStreaming(module, imports);
                } catch (e) {
                    const validResponse = module.ok && expectedResponseType(module.type);

                    if (validResponse && module.headers.get('Content-Type') !== 'application/wasm') {
                        console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                    } else { throw e; }
                }
            }

            const bytes = await module.arrayBuffer();
            return await WebAssembly.instantiate(bytes, imports);
        } else {
            const instance = await WebAssembly.instantiate(module, imports);

            if (instance instanceof WebAssembly.Instance) {
                return { instance, module };
            } else {
                return instance;
            }
        }

        function expectedResponseType(type) {
            switch (type) {
                case 'basic': case 'cors': case 'default': return true;
            }
            return false;
        }
    }

    function initSync(module) {
        if (wasm !== undefined) return wasm;


        if (module !== undefined) {
            if (Object.getPrototypeOf(module) === Object.prototype) {
                ({module} = module)
            } else {
                console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
            }
        }

        const imports = __wbg_get_imports();
        if (!(module instanceof WebAssembly.Module)) {
            module = new WebAssembly.Module(module);
        }
        const instance = new WebAssembly.Instance(module, imports);
        return __wbg_finalize_init(instance, module);
    }

    async function __wbg_init(module_or_path) {
        if (wasm !== undefined) return wasm;


        if (module_or_path !== undefined) {
            if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
                ({module_or_path} = module_or_path)
            } else {
                console.warn('using deprecated parameters for the initialization function; pass a single object instead')
            }
        }

        if (module_or_path === undefined && script_src !== undefined) {
            module_or_path = script_src.replace(/\.js$/, "_bg.wasm");
        }
        const imports = __wbg_get_imports();

        if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
            module_or_path = fetch(module_or_path);
        }

        const { instance, module } = await __wbg_load(await module_or_path, imports);

        return __wbg_finalize_init(instance, module);
    }

    return Object.assign(__wbg_init, { initSync }, exports);
})({ __proto__: null });
