extends Label

func _process(delta):
	
	var energy = get_parent().get_parent().energy
	
	self.text = str(int(energy))