class_name BitMask32Array

var array := PackedInt32Array([0])


#region Static
static func from_mask(mask: PackedInt32Array) -> BitMask32Array:
	var bitmask := BitMask32Array.new()
	mask.sort()
	bitmask.resize(mask[-1])
	bitmask.append_array(mask)
	return bitmask


static func _resize(_array: PackedInt32Array, mask:  int) -> PackedInt32Array:
	_array.resize(clampi(ceili(mask / 32.0), 1, (1 << 31) - 1))
	return _array


static func _size(_array: PackedInt32Array) -> int:
	return _get_mask(_array).size()


static func _has(_array: PackedInt32Array, mask:  int) -> bool:
	return floori(mask / 32.0) < _array.size() and (_array[mask / 32.0] & (1 << (mask % 32))) - 1 >= 0


static func _has_array(_array: PackedInt32Array, mask:  PackedInt32Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(ceili(i / 32.0) < _array.size() and (_array[i / 32.0] & (1 << (i % 32))) - 1 >= 0)
	return res


static func _append(_array: PackedInt32Array, mask:  int) -> PackedInt32Array:
	if not _has(_array, mask):
		_array[mask / 32] += (1 << (mask % 32))
	return _array


static func _append_array(_array: PackedInt32Array, mask:  PackedInt32Array) -> PackedInt32Array:
	for i in mask:
		if not _has(_array, i):
			_array[i / 32] += 1 << (i % 32)
	return _array


static func _erase(_array: PackedInt32Array, mask:  int) -> PackedInt32Array:
	if _has(_array, mask):
		_array[mask / 32] -= 1 << (mask % 32)
	return _array


static func _erase_array(_array: PackedInt32Array, mask:  PackedInt32Array) -> PackedInt32Array:
	for i in mask:
		if _has(_array, i):
			_array[i / 32] -= 1 << (i % 32)
	return _array


static func _get_mask(_array: PackedInt32Array, begin := 0, end := _array.size()) -> PackedInt32Array:
	var mask: PackedInt32Array
	for i in range(begin, end):
		for j in 32:
			if (_array[i] & (1 << j)) - 1 >= 0:
				mask.append(32 * i + j)
	return mask


static func _reverse(_array: PackedInt32Array) -> PackedInt32Array:
	for i in _array.size():
		for j in 32:
			if (_array[i] & (1 << j)) - 1 >= 0:
				_array[i] -= 1 << j
			else:
				_array[i] += 1 << j
	return _array


static func _get_multi_dim(_array: PackedInt32Array, callable: Callable) -> Array[PackedInt32Array]:
	var mask: Array[PackedInt32Array]
	for i in _get_mask(_array):
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask
#endregion


func resize(mask: int) -> void:
	array.resize(clampi(ceili(mask / 32.0), 1, (1 << 31) - 1))


func size() -> int:
	return get_mask().size()


func has(mask: int) -> bool:
	return floori(mask / 32.0) < array.size() and (array[mask / 32.0] & (1 << (mask % 32))) - 1 >= 0


func has_array(mask: PackedInt32Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(ceili(i / 32.0) < array.size() and (array[i / 32.0] & (1 << (i % 32))) - 1 >= 0)
	return res


func append(mask: int) -> void:
	if not has(mask):
		array[mask / 32] += (1 << (mask % 32)) 


func append_array(mask: PackedInt32Array) -> void:
	for i in mask:
		if not has(i):
			array[i / 32] += 1 << (i % 32)


func erase(mask: int) -> void:
	if has(mask):
		array[mask / 32] -= 1 << (mask % 32)


func erase_array(mask: PackedInt32Array) -> void:
	for i in mask:
		if has(i):
			array[i / 32] -= 1 << (i % 32)


func get_mask(begin := 0, end := array.size()) -> PackedInt32Array:
	var mask: PackedInt32Array
	for i in range(begin, end):
		for j in 32:
			if (array[i] & (1 << j)) - 1 >= 0:
				mask.append(32 * i + j)
	return mask


func reverse() -> void:
	for i in array.size():
		for j in 32:
			if (array[i] & (1 << j)) - 1 >= 0:
				array[i] -= 1 << j
			else:
				array[i] += 1 << j


func get_multi_dim(callable: Callable) -> Array[PackedInt32Array]:
	var mask: Array[PackedInt32Array]
	for i in get_mask():
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask


func clear() -> void:
	array.fill(0)
