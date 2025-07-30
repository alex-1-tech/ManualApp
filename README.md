# ManualApp

**ManualApp** — кроссплатформенное приложение на Qt6, предназначенное для составления и прохождения технических инструкций с изображениями, текстом и чек-листами.

---

## 📦 Особенности

- Чек-листы с подтверждением выполнения;
- Простое редактирование инструкций (JSON или SQLite);
- Кроссплатформенная сборка (Linux/Windows).

---

## 🧰 Технологии

- **C++17**
- **Qt6 (Core, Gui, Widgets)**
- **CMake** (3.20+)

---

## 🧑‍💻 Сборка

### 🔹 Зависимости

Убедитесь, что установлены:

- Qt6 (например, через `qt6-base-dev` или `qt6-tools`);
- CMake 3.20+;
- Компилятор с поддержкой C++17.

### 🔹 Сборка на Linux

```bash
git clone https://github.com/alex-1-tech/ManualApp
cd manualapp
mkdir build && cd build
cmake ..
make
./ManualApp
```
### 🔹 Сборка на Windows (через MinGW/Clang)
```bash
cmake -G "MinGW Makefiles" ..
mingw32-make
```
## 📁 Структура проекта

---

```bash
ManualApp/
├── src/               # Исходный код
...
├── resources.qrc      # Qt-ресурсы
├── CMakeLists.txt     # Файл сборки
└── README.md
```
