
extends Reference

class LinkedListItem:
	extends Reference
	
	var next = null
	var previous = null
	var data = {}
	
	func _init(v):
		data = v
	
	func link(other):
		other.next = self
		previous = other
	
	func unlink():
		var _next = next
		var _previous = previous
		if _previous:
			_previous.next = next
		if _next:
			_next.previous = previous

var _tail = null
var _head = _tail
var _len = 0

func size():
	return _len

func print_list():
	if _len == 0:
		print("empty list")
		return
	var temp = _head
	while temp != null:
		print_item(temp)
		temp = temp.next

func print_item(item):
	if item == _head:
		print("start")
	print(" prev: ", item.previous, " data: ", item.data, " next: ", item.next)
	if item == _tail:
		print("end")

func push_front(val):
	if _len == 0:
		_head = LinkedListItem.new(val)
		_tail = _head
	else:
		var new_head = LinkedListItem.new(val)
		_head.link(new_head)
		_head = new_head
	_len += 1

func push_back(val):
	if _len == 0:
		_head = LinkedListItem.new(val)
		_tail = _head
	else:
		var new_tail = LinkedListItem.new(val)
		new_tail.link(_tail)
		_tail = new_tail
	_len += 1

func pop_front():
	if _len == 0:
		return null
	else:
		var result = _head.data
		_head = _head.next
		if _head != null:
			_head.previous = null
		_len -= 1
		return result

func pop_back():
	if _len == 0:
		return null
	else:
		var result = _tail.data
		_tail = _tail.previous
		if _tail != null:
			_tail.next = null
		_len -= 1
		return result

func pop_best(better_func):
	if _len == 0:
		return null
	else:
		var current_best = _head
		var next = _head.next
		while next:
			if not better_func.call_func(current_best.data, next.data):
				current_best = next
			next = next.next
		if _head == current_best:
			return pop_front()
		if _tail == current_best:
			return pop_back()
		else:
			current_best.unlink()
			return current_best.data