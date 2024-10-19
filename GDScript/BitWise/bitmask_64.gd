class_name BitMask64

var bit := 0


#region Static
static func from_mask(mask: PackedInt64Array) -> BitMask64:
	var bitmask := BitMask64.new()
	bitmask.append_array(mask)
	return bitmask


static func _size(_bit: int) -> int:
	return _get_mask(_bit).size()


static func _has(_bit: int, mask: int) -> bool:
	return mask < 64 and (_bit & (1 << (mask % 64))) - 1 >= 0


static func _has_array(_bit: int, mask: PackedInt64Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(i < 64 and (_bit & (1 << (i % 64))) - 1 >= 0)
	return res


static func _append(_bit: int, mask: int) -> int:
	if not _has(_bit, mask):
		return _bit + (1 << (mask % 64)) 
	return _bit


static func _append_array(_bit: int, mask: PackedInt64Array) -> int:
	for i in mask:
		if not _has(_bit, i):
			_bit += 1 << (i % 64)
	return _bit


static func _erase(_bit: int, mask: int) -> int:
	if _has(_bit, mask):
		return _bit - 1 << (mask % 64)
	return _bit


static func _erase_array(_bit: int, mask: PackedInt64Array) -> int:
	for i in mask:
		if _has(_bit,  i):
			_bit -= 1 << (i % 64)
	return _bit


static func _get_mask(_bit: int) -> PackedInt64Array:
	var mask: PackedInt64Array
	for i in 64:
		if (_bit & (1 << i)) - 1 >= 0:
			mask.append(i)
	return mask


static func _reverse(_bit: int) -> int:
	for i in 64:
		if (_bit & (1 << i)) - 1 >= 0:
			_bit -= 1 << i
		else:
			_bit += 1 << i
	return _bit


static func _get_multi_dim(_bit: int, callable: Callable) -> Array[PackedInt32Array]:
	var mask: Array[PackedInt32Array]
	for i in _get_mask(_bit):
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask
#endregion


func size() -> int:
	return get_mask().size()


func has(mask: int) -> bool:
	return mask < 64 and (bit & (1 << (mask % 64))) - 1 >= 0


func has_array(mask: PackedInt64Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(i < 64 and (bit & (1 << (i % 64))) - 1 >= 0)
	return res


func append(mask: int) -> void:
	if not has(mask):
		bit += (1 << (mask % 64)) 


func append_array(mask: PackedInt64Array) -> void:
	for i in mask:
		if not has(i):
			bit += 1 << (i % 64)


func erase(mask: int) -> void:
	if has(mask):
		bit -= 1 << (mask % 64)


func erase_array(mask: PackedInt64Array) -> void:
	for i in mask:
		if has(i):
			bit -= 1 << (i % 64)


func get_mask() -> PackedInt64Array:
	var mask: PackedInt64Array
	for i in 64:
		if  (bit & (1 << i)) - 1 >= 0:
			mask.append(i)
	return mask


func reverse() -> void:
	for i in 64:
		if (bit & (1 << i)) - 1 >= 0:
			bit -= 1 << i
		else:
			bit += 1 << i


func get_multi_dim(callable: Callable) -> Array[PackedInt32Array]:
	var mask: Array[PackedInt32Array]
	for i in get_mask():
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask


func clear() -> void:
	bit = 0
