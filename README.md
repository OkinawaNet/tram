# Tram

Модуль `Tram` реализует конечный автомат (FSM) для управления состояниями трамвая с использованием библиотеки [Finitomata](https://hexdocs.pm/finitomata). Он описывает различные состояния трамвая и переходы между ними, а также управляет количеством пассажиров.

## Описание

Конечный автомат для трамвая имеет следующие состояния и переходы:

- **idle** (ожидание)
- **ready** (готов)
- **open** (двери открыты)
- **moving** (движется)
- **final_state** (конечное состояние)

### Переходы

1. **idle** → **ready** через событие `power_on`
2. **ready** → **open** через событие `open_doors`
3. **open** → **ready** через событие `close_doors`
4. **ready** → **moving** через событие `move`
5. **moving** → **ready** через событие `stop`
6. **ready** → **final_state** через событие `power_off` (только если нет пассажиров)
7. **ready** → **ready** через событие `power_off` (если есть пассажиры)

## Установка

Чтобы использовать модуль `Tram`, добавьте его в зависимости вашего проекта в файле `mix.exs`:

```elixir
def deps do
  [
    {:tram, git: "https://github.com/OkinawaNet/tram"}
  ]
end
```

## Использование

Вот пример использования модуля `Tram`:

```elixir
# Запуск трамвая в состоянии ожидания
{:ok, _pid} = Tram.start_link()

# Инициализация конечного автомата для трамвая
Tram.start_fsm "TramFSM", %{passengers: 0}

# Переход в состояние "ready"
Tram.transition "TramFSM", :power_on

# Открытие дверей для посадки пассажиров
Tram.transition "TramFSM", :open_doors

# Закрытие дверей после посадки/высадки пассажиров
Tram.transition "TramFSM", {:close_doors, %{passengers_entered: 3, passengers_exited: 1}}

# Начало движения трамвая
Tram.transition "TramFSM", :move

# Остановка трамвая
Tram.transition "TramFSM", :stop

# Выключение питания трамвая (только если нет пассажиров)
Tram.transition "TramFSM", :power_off

# Получение текущего состояния трамвая
Tram.state "TramFSM"
#⇒ %Tram.State{current: :final_state, data: %{passengers: 0}}

# Проверка, разрешено ли событие в текущем состоянии
Tram.allowed? "TramFSM", :move
#⇒ false

# Проверка, может ли трамвай ответить на событие
Tram.responds? "TramFSM", :open_doors
#⇒ false

# Переход в конечное состояние (выключение питания)
Tram.transition "TramFSM", :power_off
#⇒ [info] [◉ ⇄] [state: %Tram.State{current: :final_state, data: %{passengers: 0}}]

# Проверка, жив ли трамвай
Tram.alive? "TramFSM"
#⇒ false