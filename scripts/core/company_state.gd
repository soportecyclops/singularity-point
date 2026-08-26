class_name CompanyState
extends RefCounted

## Company state.
## Represents the identity and existence of the player's company.

var name: String = ""
var founded: bool = false
var company_id: String = ""
var primary_color: Color = Color.WHITE


func reset() -> void:
	name = ""
	founded = false
	company_id = ""
	primary_color = Color.WHITE
