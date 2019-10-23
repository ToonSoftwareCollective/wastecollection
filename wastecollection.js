function sortArray(inputarray) {

		var newArray = inputarray.sort();
		return newArray;
}

function sortArray2(inputarray, extraDates) {

		var newArray = inputarray.concat(extraDates);
		newArray.sort();

		return newArray;
}

