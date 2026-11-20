@tool
class_name EditorWarningsAddon  extends Node


func _get_configuration_warnings() -> PackedStringArray:
	if Engine.is_editor_hint():
		var warnings: PackedStringArray = []
		for property in get_parent().get_script().get_script_property_list():
			if property.name.containsn("COMPONENT") and property == null:
				warnings.append("%s is null." % property.name)
		return warnings
	return []
