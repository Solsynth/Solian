let wasm_bindgen = (function(exports) {
    let script_src;
    if (typeof document !== 'undefined' && document.currentScript !== null) {
        script_src = new URL(document.currentScript.src, location.href).toString();
    }

    class WorkerPool {
        static __wrap(ptr) {
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
            const ret = wasm.workerpool_new(isLikeNone(initial) ? Number.MAX_SAFE_INTEGER : (initial) >>> 0, ptr0, len0, ptr1, len1, ptr2, len2);
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
            this.__wbg_ptr = ret[0];
            WorkerPoolFinalization.register(this, this.__wbg_ptr, this);
            return this;
        }
    }
    if (Symbol.dispose) WorkerPool.prototype[Symbol.dispose] = WorkerPool.prototype.free;
    exports.WorkerPool = WorkerPool;

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
     * @param {any} config
     * @param {Uint8Array} welcome_bytes
     * @param {string} label
     * @param {Uint8Array} context
     * @param {number} key_length
     */
    function wire__crate__api__engine__MlsEngine_export_welcome_secret(port_, that, config, welcome_bytes, label, context, key_length) {
        const ptr0 = passArray8ToWasm0(welcome_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(label, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(context, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        wasm.wire__crate__api__engine__MlsEngine_export_welcome_secret(port_, that, config, ptr0, len0, ptr1, len1, ptr2, len2, key_length);
    }
    exports.wire__crate__api__engine__MlsEngine_export_welcome_secret = wire__crate__api__engine__MlsEngine_export_welcome_secret;

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
     * @param {Uint8Array} old_signer_bytes
     * @param {Uint8Array} new_signer_bytes
     * @param {Uint8Array} new_credential_identity
     * @param {Uint8Array} new_signer_public_key
     * @param {Uint8Array | null | undefined} new_credential_bytes
     * @param {any} leaf_node_capabilities
     * @param {any} leaf_node_extensions
     */
    function wire__crate__api__engine__MlsEngine_propose_self_update_with_new_signer(port_, that, group_id_bytes, old_signer_bytes, new_signer_bytes, new_credential_identity, new_signer_public_key, new_credential_bytes, leaf_node_capabilities, leaf_node_extensions) {
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
        wasm.wire__crate__api__engine__MlsEngine_propose_self_update_with_new_signer(port_, that, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, leaf_node_capabilities, leaf_node_extensions);
    }
    exports.wire__crate__api__engine__MlsEngine_propose_self_update_with_new_signer = wire__crate__api__engine__MlsEngine_propose_self_update_with_new_signer;

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
     * @param {any} not_before
     * @param {any} not_after
     * @param {any} now_unix_seconds
     * @returns {any}
     */
    function wire__crate__api__engine__check_lifetime_at(not_before, not_after, now_unix_seconds) {
        const ret = wasm.wire__crate__api__engine__check_lifetime_at(not_before, not_after, now_unix_seconds);
        return ret;
    }
    exports.wire__crate__api__engine__check_lifetime_at = wire__crate__api__engine__check_lifetime_at;

    /**
     * @param {Uint8Array} key_package_bytes
     * @returns {any}
     */
    function wire__crate__api__engine__key_package_lifetime(key_package_bytes) {
        const ptr0 = passArray8ToWasm0(key_package_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.wire__crate__api__engine__key_package_lifetime(ptr0, len0);
        return ret;
    }
    exports.wire__crate__api__engine__key_package_lifetime = wire__crate__api__engine__key_package_lifetime;

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
            __wbg_Number_3890faa6d3ff057d: function(arg0) {
                const ret = Number(arg0);
                return ret;
            },
            __wbg___wbindgen_bigint_get_as_i64_c4ecf48528083721: function(arg0, arg1) {
                const v = arg1;
                const ret = typeof(v) === 'bigint' ? v : undefined;
                getDataViewMemory0().setBigInt64(arg0 + 8 * 1, isLikeNone(ret) ? BigInt(0) : ret, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
            },
            __wbg___wbindgen_debug_string_a57024b9c6e4a48b: function(arg0, arg1) {
                const ret = debugString(arg1);
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbindgen_is_falsy_b7464e97ddc1b7a4: function(arg0) {
                const ret = !arg0;
                return ret;
            },
            __wbg___wbindgen_is_function_5e4570eb24ffa122: function(arg0) {
                const ret = typeof(arg0) === 'function';
                return ret;
            },
            __wbg___wbindgen_is_null_7d13f41e1a2d5140: function(arg0) {
                const ret = arg0 === null;
                return ret;
            },
            __wbg___wbindgen_is_object_a2790eb24c211ea0: function(arg0) {
                const val = arg0;
                const ret = typeof(val) === 'object' && val !== null;
                return ret;
            },
            __wbg___wbindgen_is_string_e6f02f0ea5f20a32: function(arg0) {
                const ret = typeof(arg0) === 'string';
                return ret;
            },
            __wbg___wbindgen_is_undefined_6cff064c44e0d823: function(arg0) {
                const ret = arg0 === undefined;
                return ret;
            },
            __wbg___wbindgen_jsval_eq_0a18949a61670320: function(arg0, arg1) {
                const ret = arg0 === arg1;
                return ret;
            },
            __wbg___wbindgen_memory_5dc2a138835b0f8e: function() {
                const ret = wasm.memory;
                return ret;
            },
            __wbg___wbindgen_module_d70c256490b5f616: function() {
                const ret = wasmModule;
                return ret;
            },
            __wbg___wbindgen_number_get_136b9679cab35cfb: function(arg0, arg1) {
                const obj = arg1;
                const ret = typeof(obj) === 'number' ? obj : undefined;
                getDataViewMemory0().setFloat64(arg0 + 8 * 1, isLikeNone(ret) ? 0 : ret, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
            },
            __wbg___wbindgen_string_get_d154f1e671052120: function(arg0, arg1) {
                const obj = arg1;
                const ret = typeof(obj) === 'string' ? obj : undefined;
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg___wbindgen_throw_bb96b2010945f0bc: function(arg0, arg1) {
                throw new Error(getStringFromWasm0(arg0, arg1));
            },
            __wbg__wbg_cb_unref_be22cc64ae6946a0: function(arg0) {
                arg0._wbg_cb_unref();
            },
            __wbg_call_35dba3c747ad7521: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.call(arg1, arg2);
                return ret;
            }, arguments); },
            __wbg_close_0c1f30aeb9a080a7: function(arg0) {
                arg0.close();
            },
            __wbg_close_baf8ba6c3102ffc3: function() { return handleError(function (arg0) {
                arg0.close();
            }, arguments); },
            __wbg_commit_ea28440d4f5a8dd8: function() { return handleError(function (arg0) {
                arg0.commit();
            }, arguments); },
            __wbg_createObjectStore_2ddc8f74181944c1: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.createObjectStore(getStringFromWasm0(arg1, arg2), arg3);
                return ret;
            }, arguments); },
            __wbg_createObjectURL_da379bd6bf9a91c6: function() { return handleError(function (arg0, arg1) {
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
            __wbg_crypto_ee03eb25b52ea298: function() { return handleError(function (arg0) {
                const ret = arg0.crypto;
                return ret;
            }, arguments); },
            __wbg_data_57d8ce4eb5f0a433: function(arg0) {
                const ret = arg0.data;
                return ret;
            },
            __wbg_decrypt_2d62773990752548: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.decrypt(arg1, arg2, arg3);
                return ret;
            }, arguments); },
            __wbg_delete_27b012593b3f623b: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.delete(arg1);
                return ret;
            }, arguments); },
            __wbg_encrypt_e8399865a6e78b21: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.encrypt(arg1, arg2, arg3);
                return ret;
            }, arguments); },
            __wbg_error_24e6ac605d438e54: function() { return handleError(function (arg0) {
                const ret = arg0.error;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            }, arguments); },
            __wbg_error_43de27aff4f7934f: function(arg0) {
                const ret = arg0.error;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_error_757e9472f8410341: function(arg0, arg1) {
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
            __wbg_error_7d496c22586cebef: function(arg0, arg1) {
                console.error(getStringFromWasm0(arg0, arg1));
            },
            __wbg_eval_62d1ea2ebeca53ad: function() { return handleError(function (arg0, arg1) {
                const ret = eval(getStringFromWasm0(arg0, arg1));
                return ret;
            }, arguments); },
            __wbg_getAllKeys_17847062bee3e3a0: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.getAllKeys(arg1);
                return ret;
            }, arguments); },
            __wbg_getAllKeys_1de66542d233a4a5: function() { return handleError(function (arg0) {
                const ret = arg0.getAllKeys();
                return ret;
            }, arguments); },
            __wbg_getAllKeys_6e99e76a110b0c43: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.getAllKeys(arg1, arg2 >>> 0);
                return ret;
            }, arguments); },
            __wbg_getRandomValues_436a51d0629d84e1: function() { return handleError(function (arg0, arg1) {
                globalThis.crypto.getRandomValues(getArrayU8FromWasm0(arg0, arg1));
            }, arguments); },
            __wbg_getRandomValues_a608c4436c19407a: function() { return handleError(function (arg0, arg1) {
                globalThis.crypto.getRandomValues(getArrayU8FromWasm0(arg0, arg1));
            }, arguments); },
            __wbg_getRandomValues_c44a50d8cfdaebeb: function() { return handleError(function (arg0, arg1) {
                arg0.getRandomValues(arg1);
            }, arguments); },
            __wbg_get_4babbbf9303c1945: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.get(arg1);
                return ret;
            }, arguments); },
            __wbg_get_8caf461d5632abc2: function(arg0, arg1, arg2) {
                const ret = arg1[arg2 >>> 0];
                var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                var len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_get_971a0c45d172643f: function() { return handleError(function (arg0, arg1) {
                const ret = Reflect.get(arg0, arg1);
                return ret;
            }, arguments); },
            __wbg_get_c0c8f8d7da0c03dd: function(arg0, arg1) {
                const ret = arg0[arg1 >>> 0];
                return ret;
            },
            __wbg_get_unchecked_e20b893aeafc3fca: function(arg0, arg1) {
                const ret = arg0[arg1 >>> 0];
                return ret;
            },
            __wbg_importKey_e7ef8e3f6cc6244a: function() { return handleError(function (arg0, arg1, arg2, arg3, arg4, arg5, arg6) {
                const ret = arg0.importKey(getStringFromWasm0(arg1, arg2), arg3, arg4, arg5 !== 0, arg6);
                return ret;
            }, arguments); },
            __wbg_instanceof_BroadcastChannel_810bbdbcded1b603: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof BroadcastChannel;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_CryptoKey_f8cc895ff237f899: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof CryptoKey;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_DedicatedWorkerGlobalScope_bd193eb4ec0d4971: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof DedicatedWorkerGlobalScope;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_ErrorEvent_89b18d7510b76ab4: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof ErrorEvent;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbDatabase_e9dd9f20c51d8d42: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBDatabase;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbFactory_8b61495ce09d6c93: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBFactory;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbOpenDbRequest_b913751ffb9239bb: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBOpenDBRequest;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbRequest_471b050024626dac: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBRequest;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_IdbTransaction_434039323c136132: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof IDBTransaction;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_MessageEvent_e4f891cbe77edb3d: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof MessageEvent;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_instanceof_Window_5625ff9937037a38: function(arg0) {
                let result;
                try {
                    result = arg0 instanceof Window;
                } catch (_) {
                    result = false;
                }
                const ret = result;
                return ret;
            },
            __wbg_isArray_6339f732981044bf: function(arg0) {
                const ret = Array.isArray(arg0);
                return ret;
            },
            __wbg_length_36bd29c6848c2144: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_5038e4965f457d02: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_7528cf2a241bef97: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_dba09af5a8c29b92: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_length_ecfa2c63d3d0d82c: function(arg0) {
                const ret = arg0.length;
                return ret;
            },
            __wbg_message_ee1169351138f81d: function(arg0, arg1) {
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
            __wbg_name_9fff0f4fdae0ca48: function(arg0, arg1) {
                const ret = arg1.name;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_new_116be93542d39019: function() {
                const ret = new Array();
                return ret;
            },
            __wbg_new_227d7c05414eb861: function() {
                const ret = new Error();
                return ret;
            },
            __wbg_new_77cc4f4f472aeb81: function(arg0) {
                const ret = new Uint8Array(arg0);
                return ret;
            },
            __wbg_new_84a929404f177239: function() { return handleError(function (arg0, arg1) {
                const ret = new Worker(getStringFromWasm0(arg0, arg1));
                return ret;
            }, arguments); },
            __wbg_new_ade13ff768bb9ea2: function() { return handleError(function (arg0, arg1) {
                const ret = new BroadcastChannel(getStringFromWasm0(arg0, arg1));
                return ret;
            }, arguments); },
            __wbg_new_ebe3e0f6837f0879: function() {
                const ret = new Object();
                return ret;
            },
            __wbg_new_from_slice_3eea173078478cfe: function(arg0, arg1) {
                const ret = new Uint8Array(getArrayU8FromWasm0(arg0, arg1));
                return ret;
            },
            __wbg_new_from_slice_8aed4f0384605526: function(arg0, arg1) {
                const ret = new Uint32Array(getArrayU32FromWasm0(arg0, arg1));
                return ret;
            },
            __wbg_new_from_slice_af1eb765183f5cf0: function(arg0, arg1) {
                const ret = new Uint16Array(getArrayU16FromWasm0(arg0, arg1));
                return ret;
            },
            __wbg_new_with_blob_sequence_and_options_8b364538325ca812: function() { return handleError(function (arg0, arg1) {
                const ret = new Blob(arg0, arg1);
                return ret;
            }, arguments); },
            __wbg_new_with_length_3ffc1c56427c525c: function(arg0) {
                const ret = new Uint8Array(arg0 >>> 0);
                return ret;
            },
            __wbg_node_84ea875411254db1: function(arg0) {
                const ret = arg0.node;
                return ret;
            },
            __wbg_now_8b265300afd5f2b9: function() {
                const ret = Date.now();
                return ret;
            },
            __wbg_objectStoreNames_94ee5410bc505cae: function(arg0) {
                const ret = arg0.objectStoreNames;
                return ret;
            },
            __wbg_objectStore_222b7add2b5c2770: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.objectStore(getStringFromWasm0(arg1, arg2));
                return ret;
            }, arguments); },
            __wbg_of_598c0ff0cd48a890: function(arg0, arg1) {
                const ret = Array.of(arg0, arg1);
                return ret;
            },
            __wbg_oldVersion_92fccbad82f5635a: function(arg0) {
                const ret = arg0.oldVersion;
                return ret;
            },
            __wbg_open_66c8b00ee562451f: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.open(getStringFromWasm0(arg1, arg2));
                return ret;
            }, arguments); },
            __wbg_open_c5ecda93515ce190: function() { return handleError(function (arg0, arg1, arg2, arg3) {
                const ret = arg0.open(getStringFromWasm0(arg1, arg2), arg3 >>> 0);
                return ret;
            }, arguments); },
            __wbg_postMessage_0bd436bcdd35e6a9: function() { return handleError(function (arg0, arg1) {
                arg0.postMessage(arg1);
            }, arguments); },
            __wbg_postMessage_6dcc1574fef77104: function() { return handleError(function (arg0, arg1) {
                arg0.postMessage(arg1);
            }, arguments); },
            __wbg_postMessage_ff0d3fa36478ee89: function() { return handleError(function (arg0, arg1) {
                arg0.postMessage(arg1);
            }, arguments); },
            __wbg_process_44c7a14e11e9f69e: function(arg0) {
                const ret = arg0.process;
                return ret;
            },
            __wbg_prototypesetcall_44c18567096b467d: function(arg0, arg1, arg2) {
                Uint16Array.prototype.set.call(getArrayU16FromWasm0(arg0, arg1), arg2);
            },
            __wbg_prototypesetcall_8cddc0588056dcdb: function(arg0, arg1, arg2) {
                Uint32Array.prototype.set.call(getArrayU32FromWasm0(arg0, arg1), arg2);
            },
            __wbg_prototypesetcall_de8e0d9553586985: function(arg0, arg1, arg2) {
                Uint8Array.prototype.set.call(getArrayU8FromWasm0(arg0, arg1), arg2);
            },
            __wbg_push_adb0107829f02d75: function(arg0, arg1) {
                const ret = arg0.push(arg1);
                return ret;
            },
            __wbg_put_49ed48c98d0c0d3c: function() { return handleError(function (arg0, arg1) {
                const ret = arg0.put(arg1);
                return ret;
            }, arguments); },
            __wbg_put_5e0ae8c80bb952a7: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.put(arg1, arg2);
                return ret;
            }, arguments); },
            __wbg_queueMicrotask_ac694eae12e92dfb: function(arg0) {
                queueMicrotask(arg0);
            },
            __wbg_queueMicrotask_be5fe34a8f4cad4d: function(arg0) {
                const ret = arg0.queueMicrotask;
                return ret;
            },
            __wbg_randomFillSync_6c25eac9869eb53c: function() { return handleError(function (arg0, arg1) {
                arg0.randomFillSync(arg1);
            }, arguments); },
            __wbg_random_b0d98802be10ff20: function() {
                const ret = Math.random();
                return ret;
            },
            __wbg_require_b4edbdcf3e2a1ef0: function() { return handleError(function () {
                const ret = module.require;
                return ret;
            }, arguments); },
            __wbg_resolve_020f95d838c6ef25: function(arg0) {
                const ret = Promise.resolve(arg0);
                return ret;
            },
            __wbg_result_0501bea148306f01: function() { return handleError(function (arg0) {
                const ret = arg0.result;
                return ret;
            }, arguments); },
            __wbg_set_8155bb79a948541b: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = Reflect.set(arg0, arg1, arg2);
                return ret;
            }, arguments); },
            __wbg_set_iv_c1e4070419376aa1: function(arg0, arg1) {
                arg0.iv = arg1;
            },
            __wbg_set_name_f5e6db43aa0c2d98: function(arg0, arg1, arg2) {
                arg0.name = getStringFromWasm0(arg1, arg2);
            },
            __wbg_set_onabort_fda794cb1089d6b5: function(arg0, arg1) {
                arg0.onabort = arg1;
            },
            __wbg_set_oncomplete_ff31bdacaa1b3558: function(arg0, arg1) {
                arg0.oncomplete = arg1;
            },
            __wbg_set_onerror_3dff0f2abceea5e9: function(arg0, arg1) {
                arg0.onerror = arg1;
            },
            __wbg_set_onerror_41278ace6abe3973: function(arg0, arg1) {
                arg0.onerror = arg1;
            },
            __wbg_set_onerror_b63034829f16949e: function(arg0, arg1) {
                arg0.onerror = arg1;
            },
            __wbg_set_onmessage_6f838578941fe42d: function(arg0, arg1) {
                arg0.onmessage = arg1;
            },
            __wbg_set_onsuccess_86d76d6974cd57e4: function(arg0, arg1) {
                arg0.onsuccess = arg1;
            },
            __wbg_set_onupgradeneeded_79b60102909f4a5e: function(arg0, arg1) {
                arg0.onupgradeneeded = arg1;
            },
            __wbg_set_type_062a978c6946048f: function(arg0, arg1, arg2) {
                arg0.type = getStringFromWasm0(arg1, arg2);
            },
            __wbg_stack_3b0d974bbf31e44f: function(arg0, arg1) {
                const ret = arg1.stack;
                const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
                const len1 = WASM_VECTOR_LEN;
                getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
                getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
            },
            __wbg_static_accessor_GLOBAL_THIS_466428f93b4eaa76: function() {
                const ret = typeof globalThis === 'undefined' ? null : globalThis;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_static_accessor_GLOBAL_c7aea38d4de089bc: function() {
                const ret = typeof global === 'undefined' ? null : global;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_static_accessor_SELF_42d4fae05e59267a: function() {
                const ret = typeof self === 'undefined' ? null : self;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_static_accessor_WINDOW_e0db14a0eba6a812: function() {
                const ret = typeof window === 'undefined' ? null : window;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_subarray_a4cc58201c7359fd: function(arg0, arg1, arg2) {
                const ret = arg0.subarray(arg1 >>> 0, arg2 >>> 0);
                return ret;
            },
            __wbg_subtle_a9e98b1d8f20164d: function(arg0) {
                const ret = arg0.subtle;
                return ret;
            },
            __wbg_target_13424fe1cdc436ac: function(arg0) {
                const ret = arg0.target;
                return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
            },
            __wbg_then_7026b513a94278a8: function(arg0, arg1) {
                const ret = arg0.then(arg1);
                return ret;
            },
            __wbg_then_72819b8d4e081fb5: function(arg0, arg1, arg2) {
                const ret = arg0.then(arg1, arg2);
                return ret;
            },
            __wbg_toString_2f0b0aec069cb718: function(arg0) {
                const ret = arg0.toString();
                return ret;
            },
            __wbg_transaction_4c999693e6e601bf: function() { return handleError(function (arg0, arg1, arg2) {
                const ret = arg0.transaction(arg1, __wbindgen_enum_IdbTransactionMode[arg2]);
                return ret;
            }, arguments); },
            __wbg_versions_276b2795b1c6a219: function(arg0) {
                const ret = arg0.versions;
                return ret;
            },
            __wbindgen_cast_0000000000000001: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [Externref], shim_idx: 869, ret: Result(Unit), inner_ret: Some(Result(Unit)) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___wasm_bindgen_25cf52d7e1a5149f___JsValue__core_ed718c3d60ebd546___result__Result_____wasm_bindgen_25cf52d7e1a5149f___JsError___true_);
                return ret;
            },
            __wbindgen_cast_0000000000000002: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [NamedExternref("Event")], shim_idx: 621, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_MessageEvent__MessageEvent______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000003: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [NamedExternref("Event")], shim_idx: 843, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_Event__Event______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000004: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [NamedExternref("IDBVersionChangeEvent")], shim_idx: 383, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_IdbVersionChangeEvent__IdbVersionChangeEvent______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000005: function(arg0, arg1) {
                // Cast intrinsic for `Closure(Closure { owned: true, function: Function { arguments: [], shim_idx: 620, ret: Unit, inner_ret: Some(Unit) }, mutable: true }) -> Externref`.
                const ret = makeMutClosure(arg0, arg1, wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke_______true_);
                return ret;
            },
            __wbindgen_cast_0000000000000006: function(arg0) {
                // Cast intrinsic for `F64 -> Externref`.
                const ret = arg0;
                return ret;
            },
            __wbindgen_cast_0000000000000007: function(arg0, arg1) {
                // Cast intrinsic for `Ref(Slice(U8)) -> NamedExternref("Uint8Array")`.
                const ret = getArrayU8FromWasm0(arg0, arg1);
                return ret;
            },
            __wbindgen_cast_0000000000000008: function(arg0, arg1) {
                // Cast intrinsic for `Ref(String) -> Externref`.
                const ret = getStringFromWasm0(arg0, arg1);
                return ret;
            },
            __wbindgen_cast_0000000000000009: function(arg0) {
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

    function wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke_______true_(arg0, arg1) {
        wasm.wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke_______true_(arg0, arg1);
    }

    function wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_MessageEvent__MessageEvent______true_(arg0, arg1, arg2) {
        wasm.wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_MessageEvent__MessageEvent______true_(arg0, arg1, arg2);
    }

    function wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_Event__Event______true_(arg0, arg1, arg2) {
        wasm.wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_Event__Event______true_(arg0, arg1, arg2);
    }

    function wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_IdbVersionChangeEvent__IdbVersionChangeEvent______true_(arg0, arg1, arg2) {
        wasm.wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___web_sys_9d86c62e649fdcdf___features__gen_IdbVersionChangeEvent__IdbVersionChangeEvent______true_(arg0, arg1, arg2);
    }

    function wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___wasm_bindgen_25cf52d7e1a5149f___JsValue__core_ed718c3d60ebd546___result__Result_____wasm_bindgen_25cf52d7e1a5149f___JsError___true_(arg0, arg1, arg2) {
        const ret = wasm.wasm_bindgen_25cf52d7e1a5149f___convert__closures_____invoke___wasm_bindgen_25cf52d7e1a5149f___JsValue__core_ed718c3d60ebd546___result__Result_____wasm_bindgen_25cf52d7e1a5149f___JsError___true_(arg0, arg1, arg2);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }


    const __wbindgen_enum_IdbTransactionMode = ["readonly", "readwrite", "versionchange", "readwriteflush", "cleanup"];
    const WorkerPoolFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_workerpool_free(ptr, 1));

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
        return decodeText(ptr >>> 0, len);
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

    let wasmModule, wasmInstance, wasm;
    function __wbg_finalize_init(instance, module) {
        wasmInstance = instance;
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
            if (!module.ok) {
                throw new Error(`failed to fetch Wasm: ${module.status} ${module.statusText} fetching '${module.url}'`);
            }

            if (typeof WebAssembly.instantiateStreaming === 'function') {
                try {
                    return await WebAssembly.instantiateStreaming(module, imports);
                } catch (e) {
                    const validResponse = expectedResponseType(module.type);

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
