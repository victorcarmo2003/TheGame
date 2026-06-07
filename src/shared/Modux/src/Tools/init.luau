local function WaitForChildOfClass(parent, className)
	local child = parent:FindFirstChildOfClass(className)
	while not child do
		child = parent.ChildAdded:Wait()
		if child.ClassName ~= className then
			child = nil
		end
	end
	return child
end

return {
	WaitForChildOfClass = WaitForChildOfClass,
}
