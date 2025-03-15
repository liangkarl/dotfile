testpath: ## Echo PATH
	PATH=$$PATH
	@echo $$PATH

prerequisites.%:
	@echo recipe here
	@echo from $@ here

target.1.o target.2.gz dir/target.3.o: prerequisites.1 prerequisites.2 | prerequisites.3
	@echo -e '@: "$@"' is 'file name of the target'
	@echo -e '%: "$%"' is 'name of the archive member'
	@echo -e '<: "$<"' is 'name of the first prerequisite'
	@echo -e '?: "$?"' is 'names of all prerequisites newer than the target'
	@echo -e '^: "$^"' is 'names of all prerequisites'
	@echo -e '|: "$|"' is 'names of all the order-only prerequisites'
	@echo -e '*: "$*"' is 'stem with which an implicit rule matches'
	@echo -e '@D: "$(@D)"' is 'the directory part'
	@echo -e '@F: "$(@F)"' is 'the file-within-directory part'

.PHONY: target.% prerequisites1 prerequisites2 testpath
