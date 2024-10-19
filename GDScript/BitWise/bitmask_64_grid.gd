class_name BitMask64Grid

var grid := PackedInt64Array([0])
var grid_size := Vector3i.ONE * 4


#region Static
static func from_mask(mask: Array[Vector3i], _size: Vector3i) -> BitMask64Grid:
	var bitmask := BitMask64Grid.new()
	bitmask.resize(_size)
	bitmask.append_array(mask)
	return bitmask


static func _size(_grid: PackedInt64Array, _grid_size: Vector3i) -> int:
	return _get_mask(_grid, _grid_size).size()


static func _has(_grid: PackedInt64Array, mask: int) -> bool:
	return mask < _grid.size() * 64 and ((_grid[mask / 64]) & (1 << (mask % 64))) - 1 >= 0


static func _has_v(_grid: PackedInt64Array, _grid_size: Vector3i, mask: Vector3i) -> bool:
	var block := mask.x / 4 + (mask.y / 4) * (_grid_size.x / 4) + (mask.z / 4) * (_grid_size.x / 4) * (_grid_size.y / 4)
	return mask.x < _grid_size.x and mask.y < _grid_size.y and mask.z < _grid_size.z and (_grid[block] & (1 << (((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4) % 64))) - 1 >= 0


static func _has_array(_grid: PackedInt64Array, mask: PackedInt64Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(i < _grid.size() * 64 and ((_grid[i / 64]) & (1 << (i % 64))) - 1 >= 0)
	return res


static func _has_v_array(_grid: PackedInt64Array, _grid_size: Vector3i, mask: Array[Vector3i]) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		var block := i.x / 4 + (i.y / 4) * (_grid_size.x / 4) + (i.z / 4) * (_grid_size.x / 4) * (_grid_size.y / 4)
		res.append(i.x < _grid_size.x and i.y < _grid_size.y and i.z < _grid_size.z and (_grid[block] & ((1 << ((i.x % 4) + (i.y % 4) * 4 + (i.z % 4) * 4 * 4) % 64))) - 1 >= 0)
	return res


static func _append(_grid:PackedInt64Array, _grid_size: Vector3i, mask: Vector3i) -> PackedInt64Array:
	if not _has_v(_grid, _grid_size, mask):
		var block := mask.x / 4 + (mask.y / 4) * (_grid_size.x / 4) + (mask.z / 4) * (_grid_size.x / 4) * (_grid_size.y / 4)
		_grid[block] += 1 << ((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4)
	return _grid


static func _append_array(_grid: PackedInt64Array, _grid_size: Vector3i, mask: Array[Vector3i]) -> PackedInt64Array:
	for i in mask:
		if not _has_v(_grid, _grid_size, i):
			var block := i.x / 4 + (i.y / 4) * (_grid_size.x / 4) + (i.z / 4) * (_grid_size.x / 4) * (_grid_size.y / 4)
			_grid[block] += 1 << ((i.x % 4) + (i.y % 4) * 4 + (i.z % 4) * 4 * 4)
	return _grid


static func _erase(_grid: PackedInt64Array, mask: int) -> PackedInt64Array:
	if _has(_grid, mask):
		_grid[mask / 64] -= 1 << (mask % 64)
	return _grid


static func _erase_v(_grid: PackedInt64Array, _grid_size: Vector3i, mask: Vector3i) -> PackedInt64Array:
	if _has_v(_grid, _grid_size, mask):
		var block := mask.x / 4 + (mask.y / 4) * (_grid_size.x / 4) + (mask.z / 4) * (_grid_size.x / 4) * (_grid_size.y / 4)
		_grid[block] -= 1 << ((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4)
	return _grid


static func _erase_array(_grid: PackedInt64Array, mask: PackedInt64Array) -> PackedInt64Array:
	for i in mask:
		if _has(_grid, i):
			_grid[(i - (i % 64)) / 64] -= 1 << (i % 64)
	return _grid


static func _erase_v_array(_grid: PackedInt64Array, _grid_size: Vector3i, mask: Array[Vector3i]) -> PackedInt64Array:
	for i in mask:
		if _has_v(_grid, _grid_size, i):
			var block := i.x / 4 + (i.y / 4) * (_grid_size.x / 4) + (i.z / 4) * (_grid_size.x / 4) * (_grid_size.y / 4)
			_grid[block] -= 1 << ((i.x % 4) + (i.y % 4) * 4 + (i.z % 4) * 4 * 4)
	return _grid


static func _get_mask(_grid: PackedInt64Array, _grid_size: Vector3i, sort := true) -> Array[Vector3i]:
	var mask: Array[Vector3i]
	for i in _grid.size():
		for j in 64:
			if (_grid[i] & (1 << j)) - 1 >= 0:
				var x := (i * 4 + (j % 4))
				var y := ((x / _grid_size.x) * 4 + ((i % 16) / 4) + ((j % 16) / 4))
				mask.append(Vector3i(
					x % _grid_size.x,
					y % _grid_size.y,
					((j / 16) + 4 * (i / ((_grid_size.x / 4) * (_grid_size.y / 4)))) % _grid_size.z))
	if sort:
		mask.sort()
	return mask


static func _reverse(_grid: PackedInt64Array) -> PackedInt64Array:
	for i in _grid.size():
		for j in 64:
			if (_grid[i] & (1 << j)) - 1 >= 0:
				_grid[i] -= 1 << j
			else:
				_grid[i] += 1 << j
	return _grid


static func _get_multi_dim(_grid: PackedInt64Array, _grid_size: Vector3i, callable: Callable) -> Array[Array]:
	var mask: Array[Array]
	for i in _get_mask(_grid, _grid_size):
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask
#endregion


func resize(_size: Vector3i):
	_size = _size.snappedi(4).clampi(1, (2 ** 31) - 1)
	grid.resize(((_size.x / 4) * (_size.y / 4) * (_size.z / 4)))
	grid_size = _size


func size() -> int:
	return get_mask().size()


func has(mask: int) -> bool:
	return mask < grid.size() * 64 and ((grid[mask / 64]) & (1 << (mask % 64))) - 1 >= 0


func has_v(mask: Vector3i) -> bool:
	var block := (mask.x / 4 + (mask.y / 4) * (grid_size.x / 4) + (mask.z / 4) * (grid_size.x / 4) * (grid_size.y / 4))
	return mask.x < grid_size.x and mask.y < grid_size.y and mask.z < grid_size.z and (grid[block] & (1 << (((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4) % 64))) - 1 >= 0


func has_array(mask: PackedInt64Array) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		res.append(i < grid.size() * 64 and ((grid[i / 64]) & (1 << (i % 64))) - 1 >= 0)
	return res


func has_v_array(mask: Array[Vector3i]) -> Array[bool]:
	var res: Array[bool]
	for i in mask:
		var block := i.x / 4 + (i.y / 4) * (grid_size.x / 4) + (i.z / 4) * (grid_size.x / 4) * (grid_size.y / 4)
		res.append(i.x < grid_size.x and i.y < grid_size.y and i.z < grid_size.z and (grid[block] & ((1 << ((i.x % 4) + (i.y % 4) * 4 + (i.z % 4) * 4 * 4) % 64))) - 1 >= 0)
	return res


func append(mask: Vector3i) -> void:
	if not has_v(mask):
		var block := mask.x / 4 + (mask.y / 4) * (grid_size.x / 4) + (mask.z / 4) * (grid_size.x / 4) * (grid_size.y / 4)
		grid[block] += 1 << ((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4)


func append_array(mask: Array[Vector3i]) -> void:
	for i in mask:
		if not has_v(i):
			var block := i.x / 4 + (i.y / 4) * (grid_size.x / 4) + (i.z / 4) * (grid_size.x / 4) * (grid_size.y / 4)
			grid[block] += 1 << ((i.x % 4) + (i.y % 4) * 4 + (i.z % 4) * 4 * 4)


func erase(mask: int) -> void:
	if has(mask):
		grid[mask / 64] -= 1 << (mask % 64)


func erase_v(mask: Vector3i) -> void:
	if has_v(mask):
		var block := mask.x / 4 + (mask.y / 4) * (grid_size.x / 4) + (mask.z / 4) * (grid_size.x / 4) * (grid_size.y / 4)
		grid[block] -= 1 << ((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4)


func erase_array(mask: PackedInt64Array) -> void:
	for i in mask:
		if has(i):
			grid[(i - (i % 64)) / 64] -= 1 << (i % 64)


func erase_v_array(mask: Array[Vector3i]) -> void:
	for i in mask:
		if has_v(i):
			var block := i.x / 4 + (i.y / 4) * (grid_size.x / 4) + (i.z / 4) * (grid_size.x / 4) * (grid_size.y / 4)
			grid[block] -= 1 << ((i.x % 4) + (i.y % 4) * 4 + (i.z % 4) * 4 * 4)


func get_mask(sort := true) -> Array[Vector3i]:
	var mask: Array[Vector3i]
	for i in grid.size():
		for j in 64:
			if (grid[i] & (1 << j)) - 1 >= 0:
				var x := (i * 4 + (j % 4))
				var y := ((x / grid_size.x) * 4 + ((i % 16) / 4) + ((j % 16) / 4))
				mask.append(Vector3i(
					x % grid_size.x,
					y % grid_size.y,
					((j / 16) + 4 * (i / ((grid_size.x / 4) * (grid_size.y / 4)))) % grid_size.z))
	if sort:
		mask.sort()
	return mask


func reverse() -> void:
	for i in grid.size():
		for j in 64:
			if (grid[i] & (1 << j)) - 1 >= 0:
				grid[i] -= 1 << j
			else:
				grid[i] += 1 << j


func get_multi_dim(callable: Callable) -> Array[Array]:
	var mask: Array[Array]
	for i in get_mask():
		var idx := callable.call(i) as int
		mask.resize(clampi(idx + 1, mask.size(), idx + 1))
		mask[idx].append(i)
	return mask


func clear() -> void:
	grid.fill(0)
