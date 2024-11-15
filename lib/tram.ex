defmodule Tram do
  @moduledoc """
  Модуль `Tram` реализует конечный автомат для управления состояниями трамвая.

  ## Состояния и переходы

  - `idle` (ожидание)
    - Переход в `ready` (готов) при включении питания (`power_on`).

  - `ready` (готов)
    - Переход в `open` (открытие дверей) при открытии дверей (`open_doors`).
    - Переход в `moving` (движение) при начале движения (`move`).
    - Переход в `final_state` (конечное состояние) при выключении питания (`power_off`), если в трамвае нет пассажиров.
    - Переход в `ready` при выключении питания (`power_off`), если в трамвае есть пассажиры.

  - `open` (открытие дверей)
    - Переход в `ready` при закрытии дверей (`close_doors`).
    - При этом обновляется количество пассажиров в трамвае на основе данных о вошедших и вышедших пассажирах.

  - `moving` (движение)
    - Переход в `ready` при остановке (`stop`).

  """

  @fsm """
  idle --> |power_on| ready

  ready --> |open_doors| open
  open --> |close_doors| ready

  ready --> |move| moving
  moving --> |stop| ready

  ready --> |power_off| ready
  ready --> |power_off| final_state
  """

  use Finitomata, fsm: @fsm, syntax: :flowchart, listener: :mox

  @impl Finitomata
  def on_transition(:idle, :power_on, _event_payload, _),
    do: {:ok, :ready, %{data: %{passengers: 0}}}

  @impl Finitomata
  def on_transition(:ready, :open, _event_payload, state_payload),
    do: {:ok, :open, state_payload}

  @impl Finitomata
  def on_transition(
        :open,
        :close_doors,
        %{passengers_entered: passengers_entered, passengers_exited: passengers_exited},
        %{data: %{passengers: passengers}}
      ),
      do:
        {:ok, :ready, %{data: %{passengers: passengers + passengers_entered - passengers_exited}}}

  @impl Finitomata
  def on_transition(:ready, :move, _event_payload, state_payload),
    do: {:ok, :moving, state_payload}

  @impl Finitomata
  def on_transition(:moving, :stop, _event_payload, state_payload),
    do: {:ok, :ready, state_payload}

  @impl Finitomata
  def on_transition(
        :ready,
        :power_off,
        _event_payload,
        %{data: %{passengers: 0}} = state_payload
      ),
      do: {:ok, :final_state, state_payload}

  @impl Finitomata
  def on_transition(:ready, :power_off, _event_payload, state_payload),
    do: {:ok, :ready, state_payload}
end
