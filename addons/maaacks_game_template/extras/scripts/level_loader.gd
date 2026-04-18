@tool
class_name LevelLoader
extends Node
## Loads scenes into a container.

signal level_load_started
signal level_loaded
signal level_ready

@export_file("*.tscn") var loading_screen_path : String : set = set_loading_screen
## Container where the level instance will be added.
@export var level_container : AbstractGameScene
## Loads a level on start.
@export var auto_load : bool = false
@export var current_level_path : String
@export_group("Debugging")
@export var force_level : String
@export var current_level : BaseLevel

var _loading_screen : PackedScene
var _scene_path : String
var _loaded_resource : Resource
var _background_loading : bool
var _loading_screen_instance: LoadingScreenOverlaid

var is_loading : bool = false

func get_current_level_path() -> String:
	return Data.LEVELS[Data.sav.current_level_index][0]

func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_level(level_path : String = get_current_level_path()):
	if is_loading : return
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	is_loading = true
	current_level_path = level_path
	_load_level(level_path, true)
	level_load_started.emit()
	await level_loaded
	is_loading = false
	current_level = _attach_level(get_resource())
	await current_level.ready
	_loading_screen_instance.close()
	level_ready.emit()

func get_resource() -> Resource:
	var current_loaded_resource := ResourceLoader.load_threaded_get(_scene_path)
	if current_loaded_resource != null:
		_loaded_resource = current_loaded_resource
	return _loaded_resource

func _load_level(scene_path : String, uses_loading_screen: bool):
	if scene_path == null or scene_path.is_empty():
		push_error("no path given to load")
		return
	_scene_path = scene_path
	if ResourceLoader.has_cached(_scene_path):
		call_deferred("emit_signal", "level_loaded")
	ResourceLoader.load_threaded_request(_scene_path)
	if _check_loading_screen():
		_loading_screen_instance = _loading_screen.instantiate()
		_loading_screen_instance.loader = self
		add_child(_loading_screen_instance)
	set_process(true)


func reload_level():
	load_level()

func _ready():
	set_process(false)
	if auto_load:
		load_level()

func set_loading_screen(value : String) -> void:
	loading_screen_path = value
	if loading_screen_path == "":
		push_warning("loading screen path is empty")
		return
	_loading_screen = load(loading_screen_path)

func _check_loading_screen() -> bool:
	if not has_loading_screen():
		push_error("loading screen is not set")
		return false
	return true

func has_loading_screen() -> bool:
	return _loading_screen != null

func get_progress() -> float:
	if not _check_scene_path():
		return 0.0
	var progress_array : Array = []
	ResourceLoader.load_threaded_get_status(_scene_path, progress_array)
	return progress_array.pop_back()

func get_status() -> ResourceLoader.ThreadLoadStatus:
	if not _check_scene_path():
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get_status(_scene_path)

func _check_scene_path() -> bool:
	if _scene_path == null or _scene_path == "":
		push_warning("scene path is empty")
		return false
	return true

func _process(_delta) -> void:
	var status = get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			level_loaded.emit()
			set_process(false)
