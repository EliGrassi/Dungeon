extends Control

@onready var server_button := $VBoxContainer/server_start
@onready var client_button := $VBoxContainer/client_start

func _ready() -> void:
	server_button.button_down.connect(_on_server_start_pressed)
	client_button.button_down.connect(_on_client_start_pressed)

func _on_server_start_pressed() -> void:
	ServerNetworkHandler.start_server()
	ClientNetworkHandler.start_client()
	remove_menu_ui()

func _on_client_start_pressed() -> void:
	ClientNetworkHandler.start_client()
	remove_menu_ui()

func remove_menu_ui() -> void:
	queue_free()
