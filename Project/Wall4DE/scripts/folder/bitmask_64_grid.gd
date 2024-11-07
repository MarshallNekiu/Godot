class_name BitMask64Grid
extends Resource

var grid_size := Vector3i.ONE * 4
var grid := PackedInt64Array([0])


static func from_mask(mask: Array[Vector3i], _size: Vector3i) -> BitMask64Grid:
	var bitmask := BitMask64Grid.new()
	bitmask.resize(_size)
	bitmask.append_array(mask)
	return bitmask


func resize(_size: Vector3i):
	_size = _size.snappedi(4).clampi(1, (2 ** 31) - 1)
	var v := get_mask() as Array[Vector3i]
	grid.resize(((_size.x / 4) * (_size.y / 4) * (_size.z / 4)))
	grid.fill(0)
	append_array(v)
	grid_size = _size


func size() -> int:
	return get_mask().size()


func has(mask: int) -> bool:
	return mask < grid.size() * 64 and ((grid[mask / 64]) & (1 << (mask % 64))) - 1 >= 0


func has_v(mask: Vector3i) -> bool:
	for i in 3:
		if mask[i] < 0 or mask[i] >= grid_size[i]:
			return false
	var block := (mask.x / 4 + (mask.y / 4) * (grid_size.x / 4) + (mask.z / 4) * (grid_size.x / 4) * (grid_size.y / 4))
	return block < grid.size() and (grid[block] & (1 << (((mask.x % 4) + (mask.y % 4) * 4 + (mask.z % 4) * 4 * 4) % 64))) - 1 >= 0


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


func get_index_resized(idx: int, on_size: Vector3i) -> int:
	var z := idx / (grid_size.x * grid_size.y)
	var y := (idx -  z * (grid_size.x * grid_size.y)) / grid_size.x
	var v := Vector3i(idx % grid_size.x, y, z)
	return v.x + v.y * on_size.x + v.z * on_size.x * on_size.y


func grid_idx_get_v(idx: int) -> Vector3i:
	var z := idx / (grid_size.x * grid_size.y)
	var y := (idx -  z * (grid_size.x * grid_size.y)) / grid_size.x
	return Vector3i(idx % grid_size.x, y, z)


func grid_v_get_index(v: Vector3i) -> int:
	return v.x + v.y * grid_size.x + v.z * grid_size.x * grid_size.y


func grid_get_index() -> PackedInt32Array:
	var idx: PackedInt32Array
	for i in grid.size():
		for j in 64:
			if (grid[i] & (1 << j)) - 1 >= 0:
				var x := (i * 4 + (j % 4))
				var y := ((i % ((grid_size.x / 4) * (grid_size.y / 4))) / (grid_size.x / 4)) * 4 + (j % 16) / 4
				var mask := Vector3i(
					x % grid_size.x,
					y % grid_size.y,
					((j / 16) + 4 * (i / ((grid_size.x / 4) * (grid_size.y / 4)))) % grid_size.z)
				idx.append(mask.x + mask.y * grid_size.y + mask.z * grid_size.x * grid_size.y)
	idx.sort()
	return idx


func get_mask(sort := true) -> Array[Vector3i]:
	var mask: Array[Vector3i]
	for i in grid.size():
		for j in 64:
			if (grid[i] & (1 << j)) - 1 >= 0:
				var x := (i * 4 + (j % 4))
				var y := ((i % ((grid_size.x / 4) * (grid_size.y / 4))) / (grid_size.x / 4)) * 4 + (j % 16) / 4
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
