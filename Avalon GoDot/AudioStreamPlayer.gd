extends AudioStreamPlayer

func _process(delta):
	if self.playing == false:
		self.playing = true