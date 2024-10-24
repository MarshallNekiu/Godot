class_name BitMask64Array

var array := PackedInt64Array([0])


#region Static
static func from_mask(mask: PackedInt64Array) -> BitMask64Array:
	var bitmask := BitMask64Array.new()
	mask.sort()
	bitmask.resize(mask[-1])
	bitmask.append_array(mask)
	return bitmask


static func _resize(_array: PackedInt64Array, mask:  int) -> PackedInt64Array:
	_array.resize(clampi(ceili(mask / 64.0), 1, (1 << 63) - 1))
	return _array


static func _size(_array: PackedInt64Array) -> int:
	return _get_mask(_array).size()


static func _has(_array: PackedInt64Array, mask:  int) -> bool:
	return floori(mask / 64.0) < _array.size() and (_array[mask / 64.0] & (1 << (mask % 64))) - 1 >= 0


static func _has_array(_array: PackedInt64Array, mask:  PackedInt64Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(ceili(i / 64.0) < _array.size() and (_array[i / 64.0] & (1 << (i % 64))) - 1 >= 0)
	return res


static func _append(_array: PackedInt64Array, mask:  int) -> PackedInt64Array:
	if not _has(_array, mask):
		_array[mask / 64] += 1 << (mask % 64)
	return _array


static func _append_array(_array: PackedInt64Array, mask:  PackedInt64Array) -> PackedInt64Array:
	for i in mask:
		if not _has(_array, i):
			_array[i / 64] += 1 << (i % 64)
	return _array


static func _erase(_array: PackedInt64Array, mask:  int) -> PackedInt64Array:
	if _has(_array, mask):
		_array[mask / 64] -= 1 << (mask % 64)
	return _array


static func _erase_array(_array: PackedInt64Array, mask:  PackedInt64Array) -> PackedInt64Array:
	for i in mask:
		if _has(_array, i):
			_array[i / 64] -= 1 << (i % 64)
	return _array


static func _get_mask(_array: PackedInt64Array, begin := 0, end := _array.size()) -> PackedInt64Array:
	var mask: PackedInt64Array
	for i in range(begin, end):
		for j in 64:
			if (_array[i] & (1 << j)) - 1 >= 0:
				mask.append(64 * i + j)
	return mask


static func _reverse(_array: PackedInt64Array) -> PackedInt64Array:
	for i in _array.size():
		for j in 64:
			if (_array[i] & (1 << j)) - 1 >= 0:
				_array[i] -= 1 << j
			else:
				_array[i] += 1 << j
	return _array


static func _get_multi_dim(_array: PackedInt64Array, callable: Callable) -> Array[PackedInt64Array]:
	var mask: Array[PackedInt64Array]
	for i in _get_mask(_array):
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask
#endregion


func resize(mask: int) -> void:
	array.resize(clampi(ceili(mask / 64.0), 1, (1 << 63) - 1))


func size() -> void:
	return get_mask().size()


func clear() -> void:
	array.fill(0)


func has(mask: int) -> bool:
	return ceili(mask / 64.0) < array.size() and (array[mask / 64.0] & (1 << (mask % 64))) - 1 >= 0


func has_array(mask: PackedInt64Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(ceili(i / 64.0) < array.size() and (array[i / 64.0] & (1 << (i % 64))) - 1 >= 0)
	return res


func append(mask: int) -> void:
	if not has(mask):
		array[mask / 64] += 1 << (mask % 64)


func append_array(mask: PackedInt64Array) -> void:
	for i in mask:
		if not has(i):
			array[i / 64] += 1 << (i % 64)


func erase(mask: int) -> void:
	if has(mask):
		array[mask / 64] -= 1 << (mask % 64)


func erase_array(mask: PackedInt64Array) -> void:
	for i in mask:
		if has(i):
			array[i / 64] -= 1 << (i % 64)


func get_mask(begin := 0, end := array.size()) -> PackedInt64Array:
	var mask: PackedInt64Array
	for i in range(begin, end):
		for j in 64:
			if (array[i] & (1 << j)) - 1 >= 0:
				mask.append(64 * i + j)
	return mask


func reverse() -> void:
	for i in array.size():
		for j in 64:
			if (array[i] & (1 << j)) - 1 >= 0:
				array[i] -= 1 << j
			else:
				array[i] += 1 << j


func get_multi_dim(callable: Callable) -> Array[PackedInt64Array]:
	var mask: Array[PackedInt64Array]
	for i in get_mask():
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask
