retry() {
	for i in $(1:5); do
		$1 && break || echo "try again"
	done
}

parse() {
	lib=${1##*/system/}
	
}

flashlib() {
	retry "adb root"
	retry "adb remount"
	retry "get $1 ."
}

flashimg() {


}
