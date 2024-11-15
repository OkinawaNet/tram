defmodule Tram do
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
        %{data: %{passengers: passengers}} = state_payload
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
