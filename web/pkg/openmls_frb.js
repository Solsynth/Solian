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
            const ptr0 = passArrayJsValueToWasm0(tests, wasm.__wbindgen_malloc);
            const len0 = WASM_VECTOR_LEN;
            const ret = wasm.wasmbindgentestcontext_run(this.__wbg_ptr, ptr0, len0);
            return ret;
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
         * @param {string | null} [wasm_bindgen_name]
         * @returns {WorkerPool}
         */
        static new(initial, script_src, worker_js_preamble, wasm_bindgen_name) {
            var ptr0 = isLikeNone(script_src) ? 0 : passStringToWasm0(script_src, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            var len0 = WASM_VECTOR_LEN;
            var ptr1 = isLikeNone(worker_js_preamble) ? 0 : passStringToWasm0(worker_js_preamble, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            var len1 = WASM_VECTOR_LEN;
            var ptr2 = isLikeNone(wasm_bindgen_name) ? 0 : passStringToWasm0(wasm_bindgen_name, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            var len2 = WASM_VECTOR_LEN;
            const ret = wasm.workerpool_new(isLikeNone(initial) ? 0x100000001 : (initial) >>> 0, ptr0, len0, ptr1, len1, ptr2, len2);
            if (ret[2]) {
                throw takeFromExternrefTable0(ret[1]);
            }
            return WorkerPool.__wrap(ret[0]);
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
         * @param {string} wasm_bindgen_name
         */
        constructor(initial, script_src, worker_js_preamble, wasm_bindgen_name) {
            const ptr0 = passStringToWasm0(script_src, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len0 = WASM_VECTOR_LEN;
            const ptr1 = passStringToWasm0(worker_js_preamble, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len1 = WASM_VECTOR_LEN;
            const ptr2 = passStringToWasm0(wasm_bindgen_name, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len2 = WASM_VECTOR_LEN;
            const ret = wasm.workerpool_new_raw(initial, ptr0, len0, ptr1, len1, ptr2, len2);
            if (ret[2]) {
                throw takeFromExternrefTable0(ret[1]);
            }
            this.__wbg_ptr = ret[0] >>> 0;
            WorkerPoolFinalization.register(this, this.__wbg_ptr, this);
            return this;
        }
    }
    if (Symbol.dispose) WorkerPool.prototype[Symbol.dispose] = WorkerPool.prototype.free;
    exports.WorkerPool = WorkerPool;

    /**
     * Used to read benchmark data, and then the runner stores it on the local disk.
     * @returns {Uint8Array | undefined}
     */
    function __wbgbench_dump() {
        const ret = wasm.__wbgbench_dump();
        let v1;
        if (ret[0] !== 0) {
            v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v1;
    }
    exports.__wbgbench_dump = __wbgbench_dump;

    /**
     * Used to write previous benchmark data before the benchmark, for later comparison.
     * @param {Uint8Array} baseline
     */
    function __wbgbench_import(baseline) {
        const ptr0 = passArray8ToWasm0(baseline, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.__wbgbench_import(ptr0, len0);
    }
    exports.__wbgbench_import = __wbgbench_import;

    /**
     * Handler for `console.debug` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_debug(args) {
        wasm.__wbgtest_console_debug(args);
    }
    exports.__wbgtest_console_debug = __wbgtest_console_debug;

    /**
     * Handler for `console.error` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_error(args) {
        wasm.__wbgtest_console_error(args);
    }
    exports.__wbgtest_console_error = __wbgtest_console_error;

    /**
     * Handler for `console.info` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_info(args) {
        wasm.__wbgtest_console_info(args);
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
        wasm.__wbgtest_console_log(args);
    }
    exports.__wbgtest_console_log = __wbgtest_console_log;

    /**
     * Handler for `console.warn` invocations. See above.
     * @param {Array<any>} args
     */
    function __wbgtest_console_warn(args) {
        wasm.__wbgtest_console_warn(args);
    }
    exports.__wbgtest_console_warn = __wbgtest_console_warn;

    /**
     * @returns {Uint8Array | undefined}
     */
    function __wbgtest_cov_dump() {
        const ret = wasm.__wbgtest_cov_dump();
        let v1;
        if (ret[0] !== 0) {
            v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v1;
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
            var ptr0 = isLikeNone(env) ? 0 : passStringToWasm0(env, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            var len0 = WASM_VECTOR_LEN;
            const ptr1 = passStringToWasm0(temp_dir, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len1 = WASM_VECTOR_LEN;
            const ret = wasm.__wbgtest_coverage_path(ptr0, len0, pid, ptr1, len1, module_signature);
            deferred3_0 = ret[0];
            deferred3_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
        }
    }
    exports.__wbgtest_coverage_path = __wbgtest_coverage_path;

    /**
     * @returns {bigint | undefined}
     */
    function __wbgtest_module_signature() {
        const ret = wasm.__wbgtest_module_signature();
        return ret[0] === 0 ? undefined : BigInt.asUintN(64, ret[1]);
    }
    exports.__wbgtest_module_signature = __wbgtest_module_signature;

    /**
     * @param {number} call_id
     * @param {any} ptr_
     * @param {number} rust_vec_len_
     * @param {number} data_len_
     */
    function frb_dart_fn_deliver_output(call_id, ptr_, rust_vec_len_, data_len_) {
        wasm.frb_dart_fn_deliver_output(call_id, ptr_, rust_vec_len_, data_len_);
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
        const ret = wasm.frb_dart_opaque_dart2rust_encode(handle, dart_handler_port);
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
        return ret;
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
        wasm.frb_pde_ffi_dispatcher_primary(func_id, port_, ptr_, rust_vec_len_, data_len_);
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
        const ret = wasm.frb_pde_ffi_dispatcher_sync(func_id, ptr_, rust_vec_len_, data_len_);
        return ret;
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
        const ptr0 = passArrayJsValueToWasm0(transfer, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.receive_transfer_closure(payload, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
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
        wasm.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine(ptr);
    }
    exports.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine = rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsEngine;

    /**
     * @param {number} ptr
     */
    function rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair(ptr) {
        wasm.rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMlsSignatureKeyPair(ptr);
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
        return ret;
    }
    exports.wire__crate__api__config__mls_group_config_default_config = wire__crate__api__config__mls_group_config_default_config;

    /**
     * @param {Uint8Array} identity
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_basic(identity) {
        const ptr0 = passArray8ToWasm0(identity, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__credential__MlsCredential_basic(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_basic = wire__crate__api__credential__MlsCredential_basic;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_certificates(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_certificates(that);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_certificates = wire__crate__api__credential__MlsCredential_certificates;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_credential_type(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_credential_type(that);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_credential_type = wire__crate__api__credential__MlsCredential_credential_type;

    /**
     * @param {Uint8Array} bytes
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_deserialize(bytes) {
        const ptr0 = passArray8ToWasm0(bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__credential__MlsCredential_deserialize(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_deserialize = wire__crate__api__credential__MlsCredential_deserialize;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_identity(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_identity(that);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_identity = wire__crate__api__credential__MlsCredential_identity;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_serialize(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_serialize(that);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_serialize = wire__crate__api__credential__MlsCredential_serialize;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_serialized_content(that) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_serialized_content(that);
        return ret;
    }
    exports.wire__crate__api__credential__MlsCredential_serialized_content = wire__crate__api__credential__MlsCredential_serialized_content;

    /**
     * @param {any} certificate_chain
     * @returns {any}
     */
    function wire__crate__api__credential__MlsCredential_x509(certificate_chain) {
        const ret = wasm.wire__crate__api__credential__MlsCredential_x509(certificate_chain);
        return ret;
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_add_members(port_, that, ptr0, len0, ptr1, len1, key_packages_bytes);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_add_members_without_update(port_, that, ptr0, len0, ptr1, len1, key_packages_bytes);
    }
    exports.wire__crate__api__engine__MlsEngine_add_members_without_update = wire__crate__api__engine__MlsEngine_add_members_without_update;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_clear_pending_commit(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_clear_pending_commit(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_clear_pending_commit = wire__crate__api__engine__MlsEngine_clear_pending_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_clear_pending_proposals(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_clear_pending_proposals(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_clear_pending_proposals = wire__crate__api__engine__MlsEngine_clear_pending_proposals;

    /**
     * @param {any} port_
     * @param {any} that
     */
    function wire__crate__api__engine__MlsEngine_close(port_, that) {
        wasm.wire__crate__api__engine__MlsEngine_close(port_, that);
    }
    exports.wire__crate__api__engine__MlsEngine_close = wire__crate__api__engine__MlsEngine_close;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_commit_to_pending_proposals(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_commit_to_pending_proposals(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_commit_to_pending_proposals = wire__crate__api__engine__MlsEngine_commit_to_pending_proposals;

    /**
     * @param {any} port_
     * @param {string} db_path
     * @param {Uint8Array} encryption_key
     */
    function wire__crate__api__engine__MlsEngine_create(port_, db_path, encryption_key) {
        const ptr0 = passStringToWasm0(db_path, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(encryption_key, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create(port_, ptr0, len0, ptr1, len1);
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
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(group_id) ? 0 : passArray8ToWasm0(group_id, wasm.__wbindgen_malloc);
        var len3 = WASM_VECTOR_LEN;
        var ptr4 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        var len4 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_group(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4);
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
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(group_id) ? 0 : passArray8ToWasm0(group_id, wasm.__wbindgen_malloc);
        var len3 = WASM_VECTOR_LEN;
        var ptr4 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        var len4 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_group_with_builder(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, lifetime_seconds, group_context_extensions, leaf_node_extensions, capabilities, ptr4, len4);
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
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        var len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_key_package(port_, that, ciphersuite, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
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
        const ptr0 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        var len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_key_package_with_options(port_, that, ciphersuite, ptr0, len0, ptr1, len1, ptr2, len2, options, ptr3, len3);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(message, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        var ptr3 = isLikeNone(aad) ? 0 : passArray8ToWasm0(aad, wasm.__wbindgen_malloc);
        var len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_create_message(port_, that, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
    }
    exports.wire__crate__api__engine__MlsEngine_create_message = wire__crate__api__engine__MlsEngine_create_message;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_delete_group(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_delete_group(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_delete_group = wire__crate__api__engine__MlsEngine_delete_group;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} key_package_ref_bytes
     */
    function wire__crate__api__engine__MlsEngine_delete_key_package(port_, that, key_package_ref_bytes) {
        const ptr0 = passArray8ToWasm0(key_package_ref_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_delete_key_package(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_delete_key_package = wire__crate__api__engine__MlsEngine_delete_key_package;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_export_group_context(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_group_context(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_export_group_context = wire__crate__api__engine__MlsEngine_export_group_context;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_export_group_info(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_group_info(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_export_group_info = wire__crate__api__engine__MlsEngine_export_group_info;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_export_ratchet_tree(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_ratchet_tree(port_, that, ptr0, len0);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(label, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(context, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_secret(port_, that, ptr0, len0, ptr1, len1, ptr2, len2, key_length);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_flexible_commit(port_, that, ptr0, len0, ptr1, len1, options);
    }
    exports.wire__crate__api__engine__MlsEngine_flexible_commit = wire__crate__api__engine__MlsEngine_flexible_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {any} epoch
     */
    function wire__crate__api__engine__MlsEngine_get_past_resumption_psk(port_, that, group_id_bytes, epoch) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_get_past_resumption_psk(port_, that, ptr0, len0, epoch);
    }
    exports.wire__crate__api__engine__MlsEngine_get_past_resumption_psk = wire__crate__api__engine__MlsEngine_get_past_resumption_psk;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_ciphersuite(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_ciphersuite(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_ciphersuite = wire__crate__api__engine__MlsEngine_group_ciphersuite;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_configuration(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_configuration(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_configuration = wire__crate__api__engine__MlsEngine_group_configuration;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_confirmation_tag(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_confirmation_tag(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_confirmation_tag = wire__crate__api__engine__MlsEngine_group_confirmation_tag;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_credential(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_credential(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_credential = wire__crate__api__engine__MlsEngine_group_credential;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_epoch(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_epoch(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_epoch = wire__crate__api__engine__MlsEngine_group_epoch;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_epoch_authenticator(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_epoch_authenticator(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_epoch_authenticator = wire__crate__api__engine__MlsEngine_group_epoch_authenticator;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_extensions(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_extensions(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_extensions = wire__crate__api__engine__MlsEngine_group_extensions;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_has_pending_proposals(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_has_pending_proposals(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_has_pending_proposals = wire__crate__api__engine__MlsEngine_group_has_pending_proposals;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_id(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_id(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_id = wire__crate__api__engine__MlsEngine_group_id;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_is_active(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_is_active(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_is_active = wire__crate__api__engine__MlsEngine_group_is_active;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {number} leaf_index
     */
    function wire__crate__api__engine__MlsEngine_group_member_at(port_, that, group_id_bytes, leaf_index) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_member_at(port_, that, ptr0, len0, leaf_index);
    }
    exports.wire__crate__api__engine__MlsEngine_group_member_at = wire__crate__api__engine__MlsEngine_group_member_at;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} credential_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_member_leaf_index(port_, that, group_id_bytes, credential_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_member_leaf_index(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_group_member_leaf_index = wire__crate__api__engine__MlsEngine_group_member_leaf_index;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_members(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_members(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_members = wire__crate__api__engine__MlsEngine_group_members;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_own_index(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_own_index(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_own_index = wire__crate__api__engine__MlsEngine_group_own_index;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_own_leaf_node(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_own_leaf_node(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_own_leaf_node = wire__crate__api__engine__MlsEngine_group_own_leaf_node;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_group_pending_proposals(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_group_pending_proposals(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_group_pending_proposals = wire__crate__api__engine__MlsEngine_group_pending_proposals;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {any} config
     * @param {Uint8Array} welcome_bytes
     */
    function wire__crate__api__engine__MlsEngine_inspect_welcome(port_, that, config, welcome_bytes) {
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_inspect_welcome(port_, that, config, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_inspect_welcome = wire__crate__api__engine__MlsEngine_inspect_welcome;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__engine__MlsEngine_is_closed(that) {
        const ret = wasm.wire__crate__api__engine__MlsEngine_is_closed(that);
        return ret;
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
        const ptr0 = passArray8ToWasm0(group_info_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_malloc);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_malloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        var ptr5 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        var len5 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_external_commit(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5);
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
        const ptr0 = passArray8ToWasm0(group_info_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_malloc);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(credential_identity, wasm.__wbindgen_malloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(signer_public_key, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        var ptr5 = isLikeNone(aad) ? 0 : passArray8ToWasm0(aad, wasm.__wbindgen_malloc);
        var len5 = WASM_VECTOR_LEN;
        var ptr6 = isLikeNone(credential_bytes) ? 0 : passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        var len6 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_external_commit_v2(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, skip_lifetime_validation, ptr6, len6);
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
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_malloc);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_from_welcome(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2);
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
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(ratchet_tree_bytes) ? 0 : passArray8ToWasm0(ratchet_tree_bytes, wasm.__wbindgen_malloc);
        var len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2, skip_lifetime_validation);
    }
    exports.wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options = wire__crate__api__engine__MlsEngine_join_group_from_welcome_with_options;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_leave_group(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_leave_group(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_leave_group = wire__crate__api__engine__MlsEngine_leave_group;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_leave_group_via_self_remove(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_leave_group_via_self_remove(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_leave_group_via_self_remove = wire__crate__api__engine__MlsEngine_leave_group_via_self_remove;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     */
    function wire__crate__api__engine__MlsEngine_merge_pending_commit(port_, that, group_id_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_merge_pending_commit(port_, that, ptr0, len0);
    }
    exports.wire__crate__api__engine__MlsEngine_merge_pending_commit = wire__crate__api__engine__MlsEngine_merge_pending_commit;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} message_bytes
     */
    function wire__crate__api__engine__MlsEngine_process_message(port_, that, group_id_bytes, message_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_process_message(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_process_message = wire__crate__api__engine__MlsEngine_process_message;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} message_bytes
     */
    function wire__crate__api__engine__MlsEngine_process_message_with_inspect(port_, that, group_id_bytes, message_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_process_message_with_inspect(port_, that, ptr0, len0, ptr1, len1);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(key_package_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_add(port_, that, ptr0, len0, ptr1, len1, ptr2, len2);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(payload, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_custom_proposal(port_, that, ptr0, len0, ptr1, len1, proposal_type, ptr2, len2);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(psk_id, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(psk_nonce, wasm.__wbindgen_malloc);
        const len3 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_external_psk(port_, that, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_group_context_extensions(port_, that, ptr0, len0, ptr1, len1, extensions);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_remove(port_, that, ptr0, len0, ptr1, len1, member_index);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(credential_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_remove_member_by_credential(port_, that, ptr0, len0, ptr1, len1, ptr2, len2);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_propose_self_update(port_, that, ptr0, len0, ptr1, len1, leaf_node_capabilities, leaf_node_extensions);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray32ToWasm0(member_indices, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_remove_members(port_, that, ptr0, len0, ptr1, len1, ptr2, len2);
    }
    exports.wire__crate__api__engine__MlsEngine_remove_members = wire__crate__api__engine__MlsEngine_remove_members;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} proposal_ref_bytes
     */
    function wire__crate__api__engine__MlsEngine_remove_pending_proposal(port_, that, group_id_bytes, proposal_ref_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(proposal_ref_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_remove_pending_proposal(port_, that, ptr0, len0, ptr1, len1);
    }
    exports.wire__crate__api__engine__MlsEngine_remove_pending_proposal = wire__crate__api__engine__MlsEngine_remove_pending_proposal;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__engine__MlsEngine_schema_version(that) {
        const ret = wasm.wire__crate__api__engine__MlsEngine_schema_version(that);
        return ret;
    }
    exports.wire__crate__api__engine__MlsEngine_schema_version = wire__crate__api__engine__MlsEngine_schema_version;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {Uint8Array} signer_bytes
     */
    function wire__crate__api__engine__MlsEngine_self_update(port_, that, group_id_bytes, signer_bytes) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_self_update(port_, that, ptr0, len0, ptr1, len1);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(old_signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(new_signer_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passArray8ToWasm0(new_credential_identity, wasm.__wbindgen_malloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(new_signer_public_key, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        var ptr5 = isLikeNone(new_credential_bytes) ? 0 : passArray8ToWasm0(new_credential_bytes, wasm.__wbindgen_malloc);
        var len5 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_self_update_with_new_signer(port_, that, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5);
    }
    exports.wire__crate__api__engine__MlsEngine_self_update_with_new_signer = wire__crate__api__engine__MlsEngine_self_update_with_new_signer;

    /**
     * @param {any} port_
     * @param {any} that
     * @param {Uint8Array} group_id_bytes
     * @param {any} config
     */
    function wire__crate__api__engine__MlsEngine_set_configuration(port_, that, group_id_bytes, config) {
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_set_configuration(port_, that, ptr0, len0, config);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray32ToWasm0(remove_indices, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_swap_members(port_, that, ptr0, len0, ptr1, len1, ptr2, len2, add_key_packages_bytes);
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
        const ptr0 = passArray8ToWasm0(group_id_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(signer_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_update_group_context_extensions(port_, that, ptr0, len0, ptr1, len1, extensions);
    }
    exports.wire__crate__api__engine__MlsEngine_update_group_context_extensions = wire__crate__api__engine__MlsEngine_update_group_context_extensions;

    /**
     * @param {Uint8Array} message_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__mls_message_content_type(message_bytes) {
        const ptr0 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__mls_message_content_type(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__engine__mls_message_content_type = wire__crate__api__engine__mls_message_content_type;

    /**
     * @param {Uint8Array} message_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__mls_message_extract_epoch(message_bytes) {
        const ptr0 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__mls_message_extract_epoch(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__engine__mls_message_extract_epoch = wire__crate__api__engine__mls_message_extract_epoch;

    /**
     * @param {Uint8Array} message_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__mls_message_extract_group_id(message_bytes) {
        const ptr0 = passArray8ToWasm0(message_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__mls_message_extract_group_id(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__engine__mls_message_extract_group_id = wire__crate__api__engine__mls_message_extract_group_id;

    /**
     * @param {string} _library_path
     * @returns {any}
     */
    function wire__crate__api__init__init_openmls(_library_path) {
        const ptr0 = passStringToWasm0(_library_path, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__init__init_openmls(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__init__init_openmls = wire__crate__api__init__init_openmls;

    /**
     * @returns {any}
     */
    function wire__crate__api__init__is_openmls_initialized() {
        const ret = wasm.wire__crate__api__init__is_openmls_initialized();
        return ret;
    }
    exports.wire__crate__api__init__is_openmls_initialized = wire__crate__api__init__is_openmls_initialized;

    /**
     * @param {Uint8Array} bytes
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public(bytes) {
        const ptr0 = passArray8ToWasm0(bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public = wire__crate__api__keys__MlsSignatureKeyPair_deserialize_public;

    /**
     * @param {number} ciphersuite
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_from_raw(ciphersuite, private_key, public_key) {
        const ptr0 = passArray8ToWasm0(private_key, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(public_key, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_from_raw(ciphersuite, ptr0, len0, ptr1, len1);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_from_raw = wire__crate__api__keys__MlsSignatureKeyPair_from_raw;

    /**
     * @param {number} ciphersuite
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_generate(ciphersuite) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_generate(ciphersuite);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_generate = wire__crate__api__keys__MlsSignatureKeyPair_generate;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_private_key(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_private_key(that);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_private_key = wire__crate__api__keys__MlsSignatureKeyPair_private_key;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_public_key(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_public_key(that);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_public_key = wire__crate__api__keys__MlsSignatureKeyPair_public_key;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_serialize(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_serialize(that);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_serialize = wire__crate__api__keys__MlsSignatureKeyPair_serialize;

    /**
     * @param {any} that
     * @returns {any}
     */
    function wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme(that) {
        const ret = wasm.wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme(that);
        return ret;
    }
    exports.wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme = wire__crate__api__keys__MlsSignatureKeyPair_signature_scheme;

    /**
     * @param {number} ciphersuite
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @returns {any}
     */
    function wire__crate__api__keys__serialize_signer(ciphersuite, private_key, public_key) {
        const ptr0 = passArray8ToWasm0(private_key, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(public_key, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__keys__serialize_signer(ciphersuite, ptr0, len0, ptr1, len1);
        return ret;
    }
    exports.wire__crate__api__keys__serialize_signer = wire__crate__api__keys__serialize_signer;

    /**
     * @returns {any}
     */
    function wire__crate__api__types__supported_ciphersuites() {
        const ret = wasm.wire__crate__api__types__supported_ciphersuites();
        return ret;
    }
    exports.wire__crate__api__types__supported_ciphersuites = wire__crate__api__types__supported_ciphersuites;

    function __wbg_get_imports() {
        const import0 = {
            __proto__: null,
            __wbg_Deno_09c3610c6dfa937c: function(arg0) {
                const ret = arg0.Deno;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_Number_e6ffdb596c888833: function(arg0) {
                const ret = Number(arg0);
                return ret;
            },
            __wbg_String_9d048b91bf7e503e: function(arg0, arg1) {
                const ret = String(arg1);
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbg_test_output_writeln_99c4edf819623848: function(arg0) {
                __wbg_test_output_writeln(arg0);
            },
            __wbg___wbgtest_og_console_log_c1b9fbbf239d8d92: function(arg0, arg1) {
                __wbgtest_og_console_log(getStringFromWasm0(arg0, arg1));
            },
            __wbg___wbindgen_bigint_get_as_i64_2c5082002e4826e2: function(arg0, arg1) {
                const v = arg1;
                const ret = typeof(v) === 'bigint' ? v : undefined;
                getDataViewMemory0().setBigInt64(arg0 + 8 * 1, isLikeNone(ret) ? BigInt(0) : ret, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
            },
            __wbg___wbindgen_debug_string_dd5d2d07ce9e6c57: function(arg0, arg1) {
                const ret = debugString(arg1);
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbindgen_is_falsy_c6ddfae1bb56d5ef: function(arg0) {
                const ret = !arg0;
                return ret;
            },
            __wbg___wbindgen_is_function_49868bde5eb1e745: function(arg0) {
                const ret = typeof(arg0) === 'function';
                return ret;
            },
            __wbg___wbindgen_is_null_344c8750a8525473: function(arg0) {
                const ret = arg0 === null;
                return ret;
            },
            __wbg___wbindgen_is_object_40c5a80572e8f9d3: function(arg0) {
                const val = arg0;
                const ret = typeof(val) === 'object' && val !== null;
                return ret;
            },
            __wbg___wbindgen_is_string_b29b5c5a8065ba1a: function(arg0) {
                const ret = typeof(arg0) === 'string';
                return ret;
            },
            __wbg___wbindgen_is_undefined_c0cca72b82b86f4d: function(arg0) {
                const ret = arg0 === undefined;
                return ret;
            },
            __wbg___wbindgen_jsval_eq_7d430e744a913d26: function(arg0, arg1) {
                const ret = arg0 === arg1;
                return ret;
            },
            __wbg___wbindgen_memory_73fdd881ebd2e7a3: function() {
                const ret = wasm.memory;
                return ret;
            },
            __wbg___wbindgen_module_7d79cdce5fe2ca41: function() {
                const ret = wasmModule;
                return ret;
            },
            __wbg___wbindgen_number_get_7579aab02a8a620c: function(arg0, arg1) {
                const obj = arg1;
                const ret = typeof(obj) === 'number' ? obj : undefined;
                getDataViewMemory0().setFloat64(arg0 + 8 * 1, isLikeNone(ret) ? 0 : ret, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
            },
            __wbg___wbindgen_string_get_914df97fcfa788f2: function(arg0, arg1) {
                const obj = arg1;
                const ret = typeof(obj) === 'string' ? obj : undefined;
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbindgen_throw_81fc77679af83bc6: function(arg0, arg1) {
                throw new Error(getStringFromWasm0(arg0, arg1));
            },
            __wbg__wbg_cb_unref_3c3b4f651835fbcb: function(arg0) {
                arg0._wbg_cb_unref();
            },
            __wbg_call_d578befcc3145dee: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.call(arg1, arg2);
                return ret;
            }, arguments); },
            __wbg_close_040c0e5be6c74f11: function(arg0) {
                arg0.close();
            },
            __wbg_commit_1a74f28f26c0cbd8: function() { return handleError(function (arg0) {
                arg0.commit();
            }, arguments); },
            __wbg_constructor_f1793ee407763fd7: function(arg0) {
                const ret = arg0.constructor;
                return ret;
            },
            __wbg_createObjectStore_6e567b25160be2fa: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.createObjectStore(getStringFromWasm0(arg1, arg2), arg3);
                return ret;
            }, arguments); },
            __wbg_createObjectURL_470fa06cc4a9e8f0: function() { return handleError(function (arg0, arg1) {
                const ret = URL.createObjectURL(arg1);
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            }, arguments); },
            __wbg_crypto_38df2bab126b63dc: function(arg0) {
                const ret = arg0.crypto;
                return ret;
            },
            __wbg_crypto_dcec368a49b7eddb: function() { return handleError(function (arg0) {
                const ret = arg0.crypto;
                return ret;
            }, arguments); },
            __wbg_data_60b50110c5bd9349: function(arg0) {
                const ret = arg0.data;
                return ret;
            },
            __wbg_decrypt_c9da0cda9966409a: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.decrypt(arg1, arg2, arg3);
                return ret;
            }, arguments); },
            __wbg_delete_fc24bd7dfa57938e: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.delete(arg1);
                return ret;
            }, arguments); },
            __wbg_encrypt_8c8cda84d75f138f: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.encrypt(arg1, arg2, arg3);
                return ret;
            }, arguments); },
            __wbg_error_334f0e2fd1506fda: function(arg0, arg1) {
                console.error(getStringFromWasm0(arg0, arg1));
            },
            __wbg_error_58469b8474e13592: function() { return handleError(function (arg0) {
                const ret = arg0.error;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            }, arguments); },
            __wbg_error_7bfe3b7ebaaa5936: function(arg0, arg1) {
                console.error(getStringFromWasm0(arg0, arg1));
            },
            __wbg_error_a6fa202b58aa1cd3: function(arg0, arg1) {
                let deferred0_0;
                let deferred0_1;
                try {
                    deferred0_0 = arg0;
                    deferred0_1 = arg1;
                    console.error(getStringFromWasm0(arg0, arg1));
                } finally {
                    wasm.__wbindgen_free(deferred0_0, deferred0_1, 1);
                }
            },
            __wbg_error_c57846662bf0e748: function(arg0) {
                const ret = arg0.error;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_eval_db8671e4e6469929: function() { return handleError(function (arg0, arg1) {
                const ret = eval(getStringFromWasm0(arg0, arg1));
                return ret;
            }, arguments); },
            __wbg_forEach_f44dee125f1ea1b5: function(arg0, arg1, arg2) {
                try {
                    var state0 = {a: arg1, b: arg2};
                    var cb0 = (arg0, arg1, arg2) => {
                        const a = state0.a;
                        state0.a = 0;
                        try {
                            return wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___wasm_bindgen_ebdf1a66e17b0e67___JsValue__wasm_bindgen_ebdf1a66e17b0e67___JsValue__js_sys_78958be12018ad84___Set______true_(a, state0.b, arg0, arg1, arg2);
                        } finally {
                            state0.a = a;
                        }
                    };
                    arg0.forEach(cb0);
                } finally {
                    state0.a = 0;
                }
            },
            __wbg_getAllKeys_122dfa5978e6ca9a: function() { return handleError(function (arg0) {
                const ret = arg0.getAllKeys();
                return ret;
            }, arguments); },
            __wbg_getAllKeys_ab049bbab10262c9: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.getAllKeys(arg1, arg2 >>> 0);
                return ret;
            }, arguments); },
            __wbg_getAllKeys_de3ce10f99737daa: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.getAllKeys(arg1);
                return ret;
            }, arguments); },
            __wbg_getElementById_6551bbc463da4d0b: function(arg0, arg1, arg2) {
                const ret = arg0.getElementById(getStringFromWasm0(arg1, arg2));
                return ret;
            },
            __wbg_getRandomValues_3f44b700395062e5: function() { return handleError(function (arg0, arg1) {
                globalThis.crypto.getRandomValues(getArrayU8FromWasm0(arg0, arg1));
            }, arguments); },
            __wbg_getRandomValues_76dfc69825c9c552: function() { return handleError(function (arg0, arg1) {
                globalThis.crypto.getRandomValues(getArrayU8FromWasm0(arg0, arg1));
            }, arguments); },
            __wbg_getRandomValues_c44a50d8cfdaebeb: function() { return handleError(function (arg0, arg1) {
                arg0.getRandomValues(arg1);
            }, arguments); },
            __wbg_get_4848e350b40afc16: function(arg0, arg1) {
                const ret = arg0[arg1 >>> 0];
                return ret;
            },
            __wbg_get_560cb483e5c0133e: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.get(arg1);
                return ret;
            }, arguments); },
            __wbg_get_dba5fa38b6597b3f: function(arg0, arg1, arg2) {
                const ret = arg1[arg2 >>> 0];
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_get_f96702c6245e4ef9: function() { return handleError(function (arg0, arg1) {
                const ret = Reflect.get(arg0, arg1);
                return ret;
            }, arguments); },
            __wbg_get_unchecked_7d7babe32e9e6a54: function(arg0, arg1) {
                const ret = arg0[arg1 >>> 0];
                return ret;
            },
            __wbg_importKey_444a3b620c5933b8: function() { return handleError(function (arg0, arg1, arg2, arg3, arg4, arg5, arg6) {
                const ret = arg0.importKey(getStringFromWasm0(arg1, arg2), arg3, arg4, arg5 !== 0, arg6);
                return ret;
            }, arguments); },
            __wbg_instanceof_BroadcastChannel_3fbc09456918e0dc: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof BroadcastChannel;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_CryptoKey_c7ae7491b5be7627: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof CryptoKey;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_ErrorEvent_58f9501c7ea44332: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof ErrorEvent;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbDatabase_0af111edb4be95f4: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBDatabase;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbFactory_7c303c3d8528cef3: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBFactory;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbOpenDbRequest_92df356941adf31e: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBOpenDBRequest;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbRequest_fc5918c726448f04: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBRequest;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbTransaction_de69712ce07dde97: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBTransaction;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_MessageEvent_3c68912ba847d8e1: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof MessageEvent;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_Window_c0fee4c064502536: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof Window;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_isArray_db61795ad004c139: function(arg0) {
                const ret = Array.isArray(arg0);
                return ret;
            },
            __wbg_length_0c32cb8543c8e4c8: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_1e701798fdcaa3b4: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_3804262ff442a7a3: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_6e821edde497a532: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_a4ca9e78359b5f1f: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_log_38117cf0bac015b5: function(arg0, arg1) {
                console.log(getStringFromWasm0(arg0, arg1));
            },
            __wbg_message_7367f8c7d0fa1589: function(arg0) {
                const ret = arg0.message;
                return ret;
            },
            __wbg_message_fdb8e0026739d05d: function(arg0, arg1) {
                const ret = arg1.message;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_msCrypto_bd5a034af96bcba6: function(arg0) {
                const ret = arg0.msCrypto;
                return ret;
            },
            __wbg_name_1f41e8af965630cd: function(arg0, arg1) {
                const ret = arg1.name;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_name_a3aabf638d645df3: function(arg0, arg1) {
                const ret = arg1.name;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_name_cb583806cac84fe0: function(arg0) {
                const ret = arg0.name;
                return ret;
            },
            __wbg_new_227d7c05414eb861: function() {
                const ret = new Error();
                return ret;
            },
            __wbg_new_4f9fafbb3909af72: function() {
                const ret = new Object();
                return ret;
            },
            __wbg_new_a560378ea1240b14: function(arg0) {
                const ret = new Uint8Array(arg0);
                return ret;
            },
            __wbg_new_a5be8c623d4166f9: function() { return handleError(function (arg0, arg1) {
                const ret = new BroadcastChannel(getStringFromWasm0(arg0, arg1));
                return ret;
            }, arguments); },
            __wbg_new_abad7dc3813f957c: function() { return handleError(function (arg0, arg1) {
                const ret = new Worker(getStringFromWasm0(arg0, arg1));
                return ret;
            }, arguments); },
            __wbg_new_d6846beabaecc372: function() {
                const ret = new Error();
                return ret;
            },
            __wbg_new_f3c9df4f38f3f798: function() {
                const ret = new Array();
                return ret;
            },
            __wbg_new_from_slice_2580ff33d0d10520: function(arg0, arg1) {
                const ret = new Uint8Array(getArrayU8FromWasm0(arg0, arg1));
                return ret;
            },
            __wbg_new_from_slice_798885084b9cc1d2: function(arg0, arg1) {
                const ret = new Uint32Array(getArrayU32FromWasm0(arg0, arg1));
                return ret;
            },
            __wbg_new_from_slice_d4e6804502a531e5: function(arg0, arg1) {
                const ret = new Uint16Array(getArrayU16FromWasm0(arg0, arg1));
                return ret;
            },
            __wbg_new_typed_14d7cc391ce53d2c: function(arg0, arg1) {
                try {
                    var state0 = {a: arg0, b: arg1};
                    var cb0 = (arg0, arg1) => {
                        const a = state0.a;
                        state0.a = 0;
                        try {
                            return wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___js_sys_78958be12018ad84___Function_fn_wasm_bindgen_ebdf1a66e17b0e67___JsValue_____wasm_bindgen_ebdf1a66e17b0e67___sys__Undefined___js_sys_78958be12018ad84___Function_fn_wasm_bindgen_ebdf1a66e17b0e67___JsValue_____wasm_bindgen_ebdf1a66e17b0e67___sys__Undefined_______true_(a, state0.b, arg0, arg1);
                        } finally {
                            state0.a = a;
                        }
                    };
                    const ret = new Promise(cb0);
                    return ret;
                } finally {
                    state0.a = 0;
                }
            },
            __wbg_new_with_blob_sequence_and_options_6d3c13013170615e: function() { return handleError(function (arg0, arg1) {
                const ret = new Blob(arg0, arg1);
                return ret;
            }, arguments); },
            __wbg_new_with_length_9cedd08484b73942: function(arg0) {
                const ret = new Uint8Array(arg0 >>> 0);
                return ret;
            },
            __wbg_node_84ea875411254db1: function(arg0) {
                const ret = arg0.node;
                return ret;
            },
            __wbg_now_2f7a9a7d6a44b289: function(arg0) {
                const ret = arg0.now();
                return ret;
            },
            __wbg_now_88621c9c9a4f3ffc: function() {
                const ret = Date.now();
                return ret;
            },
            __wbg_objectStoreNames_990d8e55c661828b: function(arg0) {
                const ret = arg0.objectStoreNames;
                return ret;
            },
            __wbg_objectStore_3d4cade4416cd432: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.objectStore(getStringFromWasm0(arg1, arg2));
                return ret;
            }, arguments); },
            __wbg_oldVersion_f2860d32ce6f6bd7: function(arg0) {
                const ret = arg0.oldVersion;
                return ret;
            },
            __wbg_open_254d9b392262d9ef: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.open(getStringFromWasm0(arg1, arg2));
                return ret;
            }, arguments); },
            __wbg_open_ac04ec9d75d0eeaf: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.open(getStringFromWasm0(arg1, arg2), arg3 >>> 0);
                return ret;
            }, arguments); },
            __wbg_performance_df61e7a062c356f8: function(arg0) {
                const ret = arg0.performance;
                return ret;
            },
            __wbg_postMessage_2b529c5fbb0ae01c: function() { return handleError(function (arg0, arg1) {
                arg0.postMessage(arg1);
            }, arguments); },
            __wbg_postMessage_59736484efc322cf: function() { return handleError(function (arg0, arg1) {
                arg0.postMessage(arg1);
            }, arguments); },
            __wbg_postMessage_b2f3a9b43857bbfb: function() { return handleError(function (arg0, arg1) {
                arg0.postMessage(arg1);
            }, arguments); },
            __wbg_process_44c7a14e11e9f69e: function(arg0) {
                const ret = arg0.process;
                return ret;
            },
            __wbg_prototypesetcall_3e05eb9545565046: function(arg0, arg1, arg2) {
                Uint8Array.prototype.set.call(getArrayU8FromWasm0(arg0, arg1), arg2);
            },
            __wbg_prototypesetcall_64c287a27cc24d27: function(arg0, arg1, arg2) {
                Uint16Array.prototype.set.call(getArrayU16FromWasm0(arg0, arg1), arg2);
            },
            __wbg_prototypesetcall_e42275e601e14eeb: function(arg0, arg1, arg2) {
                Uint32Array.prototype.set.call(getArrayU32FromWasm0(arg0, arg1), arg2);
            },
            __wbg_push_6bdbc990be5ac37b: function(arg0, arg1) {
                const ret = arg0.push(arg1);
                return ret;
            },
            __wbg_put_015a7e88e46a2502: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.put(arg1);
                return ret;
            }, arguments); },
            __wbg_put_4485a4012273f7ef: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.put(arg1, arg2);
                return ret;
            }, arguments); },
            __wbg_queueMicrotask_abaf92f0bd4e80a4: function(arg0) {
                const ret = arg0.queueMicrotask;
                return ret;
            },
            __wbg_queueMicrotask_df5a6dac26d818f3: function(arg0) {
                queueMicrotask(arg0);
            },
            __wbg_randomFillSync_6c25eac9869eb53c: function() { return handleError(function (arg0, arg1) {
                arg0.randomFillSync(arg1);
            }, arguments); },
            __wbg_random_a72d453e63c9558c: function() {
                const ret = Math.random();
                return ret;
            },
            __wbg_require_b4edbdcf3e2a1ef0: function() { return handleError(function () {
                const ret = module.require;
                return ret;
            }, arguments); },
            __wbg_resolve_0a79de24e9d2267b: function(arg0) {
                const ret = Promise.resolve(arg0);
                return ret;
            },
            __wbg_result_452c1006fc727317: function() { return handleError(function (arg0) {
                const ret = arg0.result;
                return ret;
            }, arguments); },
            __wbg_self_7a1e7241bc8997ba: function(arg0) {
                const ret = arg0.self;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_set_8ee2d34facb8466e: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = Reflect.set(arg0, arg1, arg2);
                return ret;
            }, arguments); },
            __wbg_set_iv_ce6d8b0673118a9a: function(arg0, arg1) {
                arg0.iv = arg1;
            },
            __wbg_set_name_118b646d7afe924f: function(arg0, arg1, arg2) {
                arg0.name = getStringFromWasm0(arg1, arg2);
            },
            __wbg_set_onabort_6b6df7a41aa97c23: function(arg0, arg1) {
                arg0.onabort = arg1;
            },
            __wbg_set_oncomplete_20fb27150b4ee0d4: function(arg0, arg1) {
                arg0.oncomplete = arg1;
            },
            __wbg_set_onerror_058cb75ccfa7d73a: function(arg0, arg1) {
                arg0.onerror = arg1;
            },
            __wbg_set_onerror_2b7dfa4e6dea4159: function(arg0, arg1) {
                arg0.onerror = arg1;
            },
            __wbg_set_onerror_3c4b5087146b11b6: function(arg0, arg1) {
                arg0.onerror = arg1;
            },
            __wbg_set_onmessage_63e13b226483da6a: function(arg0, arg1) {
                arg0.onmessage = arg1;
            },
            __wbg_set_onsuccess_f7e5b5cbed5008b1: function(arg0, arg1) {
                arg0.onsuccess = arg1;
            },
            __wbg_set_onupgradeneeded_d7e8e03a1999bf5d: function(arg0, arg1) {
                arg0.onupgradeneeded = arg1;
            },
            __wbg_set_text_content_2000e40940ae2d38: function(arg0, arg1, arg2) {
                arg0.textContent = getStringFromWasm0(arg1, arg2);
            },
            __wbg_set_type_ef754f25329c9096: function(arg0, arg1, arg2) {
                arg0.type = getStringFromWasm0(arg1, arg2);
            },
            __wbg_stack_066da4af02bc0a33: function(arg0, arg1) {
                const ret = arg1.stack;
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_stack_3b0d974bbf31e44f: function(arg0, arg1) {
                const ret = arg1.stack;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_stack_96079fa62f572149: function(arg0, arg1) {
                const ret = arg1.stack;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_stack_af5c92ab21c82a75: function(arg0) {
                const ret = arg0.stack;
                return ret;
            },
            __wbg_stack_c8cb4685c35b80ab: function(arg0) {
                const ret = arg0.stack;
                return ret;
            },
            __wbg_static_accessor_DOCUMENT_d32ec204d07a803b: function() {
                const ret = document;
                return ret;
            },
            __wbg_static_accessor_GLOBAL_THIS_a1248013d790bf5f: function() {
                const ret = typeof globalThis === 'undefined' ? null : globalThis;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_static_accessor_GLOBAL_f2e0f995a21329ff: function() {
                const ret = typeof global === 'undefined' ? null : global;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_static_accessor_SELF_24f78b6d23f286ea: function() {
                const ret = typeof self === 'undefined' ? null : self;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_static_accessor_WINDOW_59fd959c540fe405: function() {
                const ret = typeof window === 'undefined' ? null : window;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_subarray_0f98d3fb634508ad: function(arg0, arg1, arg2) {
                const ret = arg0.subarray(arg1 >>> 0, arg2 >>> 0);
                return ret;
            },
            __wbg_subtle_6b7d3b117f3b8d57: function(arg0) {
                const ret = arg0.subtle;
                return ret;
            },
            __wbg_target_732d56b173b7e87c: function(arg0) {
                const ret = arg0.target;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_text_content_8e1689dd38b895d7: function(arg0, arg1) {
                const ret = arg1.textContent;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_then_00eed3ac0b8e82cb: function(arg0, arg1, arg2) {
                const ret = arg0.then(arg1, arg2);
                return ret;
            },
            __wbg_then_a0c8db0381c8994c: function(arg0, arg1) {
                const ret = arg0.then(arg1);
                return ret;
            },
            __wbg_toString_891d991e862e1d44: function(arg0) {
                const ret = arg0.toString();
                return ret;
            },
            __wbg_toString_92f88a49bfd32789: function() { return handleError(function (arg0, arg1) {
                const ret = arg1.toString();
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            }, arguments); },
            __wbg_transaction_904b9a3920efb0b5: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.transaction(arg1, __wbindgen_enum_IdbTransactionMode[arg2]);
                return ret;
            }, arguments); },
            __wbg_versions_276b2795b1c6a219: function(arg0) {
                const ret = arg0.versions;
                return ret;
            },
            __wbindgen_cast_0000000000000001: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [Externref], shim_idx: 865, ret: Result(Unit), inner_ret: Some(Result(Unit)) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___wasm_bindgen_ebdf1a66e17b0e67___JsValue__core_9b3796e30d99ddb7___result__Result_____wasm_bindgen_ebdf1a66e17b0e67___JsError___true_);
                return ret;
            },
            __wbindgen_cast_0000000000000002: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [NamedExternref("Event")], shim_idx: 475, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_MessageEvent__MessageEvent______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000003: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [NamedExternref("Event")], shim_idx: 810, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_Event__Event______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000004: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [NamedExternref("IDBVersionChangeEvent")], shim_idx: 359, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_IdbVersionChangeEvent__IdbVersionChangeEvent______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000005: function(arg0) {
                // Cast intrinsic for `F64 -> Externref`.
                const ret = arg0;
                return ret;
            },
            __wbindgen_cast_0000000000000006: function(arg0, arg1) {
                // Cast intrinsic for `Ref(Slice(U8)) -> NamedExternref("Uint8Array")`.
                const ret = getArrayU8FromWasm0(arg0, arg1);
                return ret;
            },
            __wbindgen_cast_0000000000000007: function(arg0, arg1) {
                // Cast intrinsic for `Ref(String) -> Externref`.
                const ret = getStringFromWasm0(arg0, arg1);
                return ret;
            },
            __wbindgen_cast_0000000000000008: function(arg0) {
                // Cast intrinsic for `U64 -> Externref`.
                const ret = BigInt.asUintN(64, arg0);
                return ret;
            },
            __wbindgen_init_externref_table: function() {
                const table = wasm.__wbindgen_externrefs;
                const offset = table.grow(4);
                table.set(0, undefined);
                table.set(offset + 0, undefined);
                table.set(offset + 1, null);
                table.set(offset + 2, true);
                table.set(offset + 3, false);
            },
        };
        return {
            __proto__: null,
            "./openmls_frb_bg.js": import0,
        };
    }

    function wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_MessageEvent__MessageEvent______true_(arg0, arg1, arg2) {
        wasm.wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_MessageEvent__MessageEvent______true_(arg0, arg1, arg2);
    }

    function wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_Event__Event______true_(arg0, arg1, arg2) {
        wasm.wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_Event__Event______true_(arg0, arg1, arg2);
    }

    function wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_IdbVersionChangeEvent__IdbVersionChangeEvent______true_(arg0, arg1, arg2) {
        wasm.wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___web_sys_671990bf34def273___features__gen_IdbVersionChangeEvent__IdbVersionChangeEvent______true_(arg0, arg1, arg2);
    }

    function wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___wasm_bindgen_ebdf1a66e17b0e67___JsValue__core_9b3796e30d99ddb7___result__Result_____wasm_bindgen_ebdf1a66e17b0e67___JsError___true_(arg0, arg1, arg2) {
        const ret = wasm.wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___wasm_bindgen_ebdf1a66e17b0e67___JsValue__core_9b3796e30d99ddb7___result__Result_____wasm_bindgen_ebdf1a66e17b0e67___JsError___true_(arg0, arg1, arg2);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }

    function wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___js_sys_78958be12018ad84___Function_fn_wasm_bindgen_ebdf1a66e17b0e67___JsValue_____wasm_bindgen_ebdf1a66e17b0e67___sys__Undefined___js_sys_78958be12018ad84___Function_fn_wasm_bindgen_ebdf1a66e17b0e67___JsValue_____wasm_bindgen_ebdf1a66e17b0e67___sys__Undefined_______true_(arg0, arg1, arg2, arg3) {
        wasm.wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___js_sys_78958be12018ad84___Function_fn_wasm_bindgen_ebdf1a66e17b0e67___JsValue_____wasm_bindgen_ebdf1a66e17b0e67___sys__Undefined___js_sys_78958be12018ad84___Function_fn_wasm_bindgen_ebdf1a66e17b0e67___JsValue_____wasm_bindgen_ebdf1a66e17b0e67___sys__Undefined_______true_(arg0, arg1, arg2, arg3);
    }

    function wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___wasm_bindgen_ebdf1a66e17b0e67___JsValue__wasm_bindgen_ebdf1a66e17b0e67___JsValue__js_sys_78958be12018ad84___Set______true_(arg0, arg1, arg2, arg3, arg4) {
        wasm.wasm_bindgen_ebdf1a66e17b0e67___convert__closures_____invoke___wasm_bindgen_ebdf1a66e17b0e67___JsValue__wasm_bindgen_ebdf1a66e17b0e67___JsValue__js_sys_78958be12018ad84___Set______true_(arg0, arg1, arg2, arg3, arg4);
    }


    const __wbindgen_enum_IdbTransactionMode = ["readonly", "readwrite", "versionchange", "readwriteflush", "cleanup"];
    const WasmBindgenTestContextFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_wasmbindgentestcontext_free(ptr >>> 0, 1));
    const WorkerPoolFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_workerpool_free(ptr >>> 0, 1));

    function addToExternrefTable0(obj) {
        const idx = wasm.__externref_table_alloc();
        wasm.__wbindgen_externrefs.set(idx, obj);
        return idx;
    }

    const CLOSURE_DTORS = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(state => wasm.__wbindgen_destroy_closure(state.a, state.b));

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

    function handleError(f, args) {
        try {
            return f.apply(this, args);
        } catch (e) {
            const idx = addToExternrefTable0(e);
            wasm.__wbindgen_exn_store(idx);
        }
    }

    function isLikeNone(x) {
        return x === undefined || x === null;
    }

    function makeMutClosure(arg0, arg1, f) {
        const state = { a: arg0, b: arg1, cnt: 1 };
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
                wasm.__wbindgen_destroy_closure(state.a, state.b);
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
        for (let i = 0; i < array.length; i++) {
            const add = addToExternrefTable0(array[i]);
            getDataViewMemory0().setUint32(ptr + 4 * i, add, true);
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

    function takeFromExternrefTable0(idx) {
        const value = wasm.__wbindgen_externrefs.get(idx);
        wasm.__externref_table_dealloc(idx);
        return value;
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
