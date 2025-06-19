#macro SIGNAL_CALLBACKS_VARNAME "_@signal_callbacks"
#macro SIGNAL_ARGUMENTS_VARNAME "_@signal_arguments"

function signal_init(id) {
    if (signal_is_initialized(id)) {
        show_error($"{_signal_instance_stringify(id)}: Signals were already initialized", false);
        exit;
    }
    variable_instance_set(id, SIGNAL_CALLBACKS_VARNAME, ds_map_create());
    variable_instance_set(id, SIGNAL_ARGUMENTS_VARNAME, ds_map_create());
}

function signal_is_initialized(id) {
    return variable_instance_exists(id, SIGNAL_CALLBACKS_VARNAME);
}

function signal_cleanup(id) {
    if (!signal_is_initialized(id)) {
        show_error($"{_signal_instance_stringify(id)}: Signals were not initialized", false);
        exit;
    }
    ds_map_destroy(variable_instance_get(id, SIGNAL_CALLBACKS_VARNAME));
    ds_map_destroy(variable_instance_get(id, SIGNAL_ARGUMENTS_VARNAME));
}

function signal_add(id, signal_name) {
    if (!signal_is_initialized(id)) {
        show_error($"{_signal_instance_stringify(id)}: Signals were not initialized", false);
        exit;
    }
    if (signal_exists(id, signal_name)) {
        show_error($"{_signal_instance_stringify(id)}: Signal '{signal_name}' already exists", false);
        exit;
    }
    ds_map_add_list(variable_instance_get(id, SIGNAL_CALLBACKS_VARNAME), signal_name, ds_list_create());
    ds_map_add_list(variable_instance_get(id, SIGNAL_ARGUMENTS_VARNAME), signal_name, ds_list_create());
}

function signal_exists(id, signal_name) {
    return ds_map_exists(variable_instance_get(id, SIGNAL_CALLBACKS_VARNAME), signal_name);
}

function signal_connect(id, signal_name, callback, args) {
    if (instance_exists(id)) {
        with (id) {
            if (!signal_is_initialized(id)) {
                show_error($"{_signal_instance_stringify(id)}: Signals were not initialized", false);
                exit;
            }
            if (!signal_exists(id, signal_name)) {
                show_error($"{_signal_instance_stringify(id)}: Signal '{signal_name}' doesn't exist", false);
                exit;
            }
        }
    } else {
        show_error($"{_GMFUNCTION_}: Instance with id '{id}' doesn't exist", false);
    }
    ds_list_add(variable_instance_get(id, SIGNAL_CALLBACKS_VARNAME)[? signal_name], callback);
    ds_list_add(variable_instance_get(id, SIGNAL_ARGUMENTS_VARNAME)[? signal_name], args);
}

function signal_emit(id, signal_name, args = []) {
    if (!signal_is_initialized(id)) {
        show_error($"{_signal_instance_stringify(id)}: Signals were not initialized", false);
        exit;
    }
    if (!signal_exists(id, signal_name)) {
        show_error($"{_signal_instance_stringify(id)}: Signal '{signal_name}' doesn't exist", false);
        exit;
    }
    var
    _callbacks = variable_instance_get(id, SIGNAL_CALLBACKS_VARNAME)[? signal_name],
    _arguments = variable_instance_get(id, SIGNAL_ARGUMENTS_VARNAME)[? signal_name],
    i = 0;
    repeat (ds_list_size(_callbacks)) {
        script_execute_ext(_callbacks[| i], array_concat(args, _arguments[| i]));
        i -= 1;
    }
}

function _signal_instance_stringify(inst) {
	var _inst_string = string(inst.id);
	var _inst_string_split = string_split(_inst_string, " ");
    return $"{_inst_string_split[array_length(_inst_string_split) - 1]} ({object_get_name(inst.object_index)})";
}