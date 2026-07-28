class_name EventResource
extends Resource

@export var event_name : String = "Event"
@export_multiline var description : String = ""
@export var texture : Texture2D
@export var weight : float = 1.0
@export var options : Array[EventOptionResource] = []
