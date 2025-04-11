# Compilador e flags
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++11
INCLUDES = -Ilib/core -Ilib/gui
LIBS = -lGL -lGLU -lglut -lIL -lassimp

# Detectar sistema operacional
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    # Adiciona flags específicas do Windows se necessário
    # CXXFLAGS += -D_WIN32
    # Inclui os arquivos Windows específicos
    WINDOWS_DIR = lib/core/Windows
    WINDOWS_FILES = $(wildcard $(WINDOWS_DIR)/*.cpp)
    INCLUDES += -I$(WINDOWS_DIR)
    OBJ_WINDOWS = $(patsubst $(WINDOWS_DIR)/%.cpp,$(BUILD_DIR)/windows/%.o,$(WINDOWS_FILES))
else
    DETECTED_OS := $(shell uname -s)
    # Nenhum arquivo Windows será compilado
    WINDOWS_FILES =
    OBJ_WINDOWS =
endif

# Diretórios
SRC_DIR = src
LIB_CORE_DIR = lib/core
LIB_GUI_DIR = lib/gui
BUILD_DIR = build
BIN_DIR = bin

# Arquivos fonte
SRC_FILES = $(wildcard $(SRC_DIR)/*.cpp)
LIB_CORE_FILES = $(wildcard $(LIB_CORE_DIR)/*.cpp)
LIB_GUI_FILES = $(wildcard $(LIB_GUI_DIR)/*.cpp)

# Arquivos objeto (mantendo a estrutura de diretórios no build)
OBJ_SRC = $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/src/%.o,$(SRC_FILES))
OBJ_CORE = $(patsubst $(LIB_CORE_DIR)/%.cpp,$(BUILD_DIR)/core/%.o,$(LIB_CORE_FILES))
OBJ_GUI = $(patsubst $(LIB_GUI_DIR)/%.cpp,$(BUILD_DIR)/gui/%.o,$(LIB_GUI_FILES))
OBJ_FILES = $(OBJ_SRC) $(OBJ_CORE) $(OBJ_GUI) $(OBJ_WINDOWS)

# Nome do executável
TARGET = $(BIN_DIR)/program

# Arquivo de comandos de compilação para o clangd
COMPILE_COMMANDS = $(BUILD_DIR)/compile_commands.json

# Regra principal
all: directories $(TARGET)

# Cria os diretórios necessários
directories:
	@mkdir -p $(BUILD_DIR)/src
	@mkdir -p $(BUILD_DIR)/core
	@mkdir -p $(BUILD_DIR)/gui
	@mkdir -p $(BIN_DIR)
ifeq ($(DETECTED_OS),Windows)
	@mkdir -p $(BUILD_DIR)/windows
endif

# Regra para o executável
$(TARGET): $(OBJ_FILES)
	$(CXX) -o $@ $^ $(LIBS)

# Regra para compilar arquivos do diretório src
$(BUILD_DIR)/src/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
	@echo '{ "directory": "$(CURDIR)", "command": "$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@", "file": "$<" },' >> $(BUILD_DIR)/_compile_commands.json

# Regra para compilar arquivos do diretório lib/core
$(BUILD_DIR)/core/%.o: $(LIB_CORE_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
	@echo '{ "directory": "$(CURDIR)", "command": "$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@", "file": "$<" },' >> $(BUILD_DIR)/_compile_commands.json

# Regra para compilar arquivos do diretório lib/gui
$(BUILD_DIR)/gui/%.o: $(LIB_GUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
	@echo '{ "directory": "$(CURDIR)", "command": "$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@", "file": "$<" },' >> $(BUILD_DIR)/_compile_commands.json

# Regra para compilar arquivos do diretório lib/core/windows (apenas no Windows)
ifeq ($(DETECTED_OS),Windows)
$(BUILD_DIR)/windows/%.o: $(WINDOWS_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
	@echo '{ "directory": "$(CURDIR)", "command": "$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@", "file": "$<" },' >> $(BUILD_DIR)/_compile_commands.json
endif

# Gera o arquivo compile_commands.json para o clangd
compile_commands: clean_compile_commands
	@echo '[' > $(BUILD_DIR)/_compile_commands.json
	@$(MAKE) -s $(OBJ_FILES)
	@sed '$$s/,$$//' $(BUILD_DIR)/_compile_commands.json > $(BUILD_DIR)/_compile_commands_fixed.json
	@echo ']' >> $(BUILD_DIR)/_compile_commands_fixed.json
	@mv $(BUILD_DIR)/_compile_commands_fixed.json $(COMPILE_COMMANDS)
	@rm -f $(BUILD_DIR)/_compile_commands.json
	@echo "Arquivo compile_commands.json gerado em $(COMPILE_COMMANDS)"
	@ln -sf $(CURDIR)/$(COMPILE_COMMANDS) $(CURDIR)/compile_commands.json

# Limpa o arquivo de comandos de compilação parcial
clean_compile_commands:
	@rm -f $(BUILD_DIR)/_compile_commands.json
	@rm -f $(BUILD_DIR)/_compile_commands_fixed.json
	@rm -f $(COMPILE_COMMANDS)
	@rm -f $(CURDIR)/compile_commands.json

# Limpa os arquivos gerados
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

# Executa o programa
run: all
	./$(TARGET)

# Regra para ver quais arquivos serão compilados
debug:
	@echo "Sistema Operacional: $(DETECTED_OS)"
	@echo "SRC files: $(SRC_FILES)"
	@echo "CORE files: $(LIB_CORE_FILES)"
	@echo "GUI files: $(LIB_GUI_FILES)"
ifeq ($(DETECTED_OS),Windows)
	@echo "WINDOWS files: $(WINDOWS_FILES)"
endif
	@echo "OBJ files: $(OBJ_FILES)"

.PHONY: all directories clean run debug compile_commands clean_compile_commands
