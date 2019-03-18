extends 'res://LinkedList.gd'

func pop_all():
	var temp_array = []
	while _len > 0:
		temp_array.push_back(pop_front())
	return temp_array

func push_all(array):
	while array.size() > 0:
		push_back(array.pop_front())

func pop(node):
	if _head == node:
		return pop_front()
	if _tail == node:
		return pop_back()
	else:
		node.unlink()
		return node.data

func pop_by_number(number):
	if _len == 0:
		return null
	else:
		var temp = _head
		while temp != null:
			if temp.data.get_number() == number:
				return pop(temp)
			temp = temp.next
		return null

func add_point_to_all():
	var temp = _head
	while temp != null:
		temp.data.increment_score_by(1)
		temp = temp.next

func has_winner(winning_score):
	if _len == 0:
		return false
	var temp = _head
	while temp != null:
		if temp.data.get_score() >= winning_score:
			return true
		temp = temp.next
	return false

func pop_all_ordered_by_highest_score(): #clears list as well
	var ordered = []
	while _len > 0:
		var temp = _head
		var leader = temp
		var high_score = 0
		while temp != null:
			if temp.data.get_score() > high_score:
				high_score = temp.data.get_score()
				leader = temp
			temp = temp.next
		ordered.push_back(pop(leader))
	return ordered