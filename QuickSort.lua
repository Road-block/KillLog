--[[

]]

-- lua's table.sort function has bugs so I wrote my own
function QuickSort(array, comp, low, high)
	-- If not specified sort entire array
	if (not high or not low) then
		high = table.getn(array);
		low = 1;
	end
	-- Terminateing Condition
	if (high == low ) then 
		return; 
	end
	-- Get Pivot
	local middle = math.floor((low+high)/2); 
	if comp(array[low], array[middle]) and comp(array[low], array[high]) then
		if comp(array[middle], array[high]) then
			array[middle], array[low] = array[low], array[middle];
		else
			array[high], array[low] = array[low], array[high];
		end
	elseif comp(array[high], array[low]) and comp(array[middle], array[low]) then
		if comp(array[middle], array[high]) then
			array[high], array[low] = array[low], array[high];
		else
			array[middle], array[low] = array[low], array[middle];
		end
	end
	-- Pivot in Low now so now we partition
	local sortedLow = low+1;
	local sortedHigh = high;
	
	while (sortedLow < sortedHigh) do
		while (comp(array[sortedLow], array[low])) do
			sortedLow = sortedLow + 1;
		end
		while (comp(array[low], array[sortedHigh])) do
			sortedHigh = sortedHigh - 1;
		end
		if (sortedLow < sortedHigh) then
			array[sortedLow], array[sortedHigh] = array[sortedHigh], array[sortedLow];
		end
	end
	-- Only 2 values ... swap if necesary
	if low + 1 == high then
		if comp(array[high], array[low]) then
			array[high], array[low] = array[low], array[high];
		end
		pivot = low; 
	elseif sortedLow + 1 == sortedHigh then
		pivot = sortedLow;
	else
		pivot = sortedHigh;
	end
	array[pivot], array[low] = array[low], array[pivot];
	-- We are all partitioned ... time to recurse
	if pivot > low then 
		QuickSort(array, comp, low, pivot - 1);
	end
	if pivot < high  then
		QuickSort(array, comp, pivot + 1, high);
	end
end
