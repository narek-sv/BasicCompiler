INPUT_FILE_NAME = 'test'
INPUT_FILE_EXTENSION = '.pas'

INPUT_FILE = '$(INPUT_FILE_NAME)$(INPUT_FILE_EXTENSION)'
ASM_FILE = '$(INPUT_FILE_NAME).s'
OBJ_FILE = '$(INPUT_FILE_NAME).o'
OUTPUT_FILE = INPUT_FILE_NAME

build:
	swift build --configuration 'release'

run:
	swift run BasicCompiler $(INPUT_FILE)
	as -o $(OBJ_FILE) $(ASM_FILE)
	ld -o $(INPUT_FILE_NAME) $(OBJ_FILE)
	
	./$(INPUT_FILE_NAME)
	echo $?
