defmodule TramTest do
  use ExUnit.Case, async: true

  doctest Tram

  import Finitomata.ExUnit
  import Mox

  alias TramTest, as: Tr

  describe "Tram" do
    setup_finitomata do
      initial_passengers = 0

      [
        fsm: [
          implementation: Tram,
          payload: %{data: %{passengers: initial_passengers}},
          options: [transition_count: 20]
        ],
        context: [passengers: initial_passengers]
      ]
    end

    test "default", %{passengers: initial_passengers} = ctx do
      assert_transition ctx, :power_on do
        :ready ->
          assert_payload do
            data.passengers ~> ^initial_passengers
          end
      end

      assert_transition ctx, :open_doors do
        :open ->
          assert_payload do
          end
      end

      assert_transition ctx, {:close_doors, %{passengers_entered: 5, passengers_exited: 0}} do
        :ready ->
          assert_payload do
            data.passengers ~> 5
          end
      end

      assert_transition ctx, :move do
        :moving ->
          assert_payload do
          end
      end

      assert_transition ctx, :stop do
        :ready ->
          assert_payload do
          end
      end

      assert_transition ctx, :open_doors do
        :open ->
          assert_payload do
          end
      end

      assert_transition ctx, {:close_doors, %{passengers_entered: 0, passengers_exited: 5}} do
        :ready ->
          assert_payload do
          end
      end

      assert_transition ctx, :power_off do
        :final_state ->
          assert_payload do
          end
      end
    end

    test "forgotten passengers", %{passengers: initial_passengers} = ctx do
      assert_transition ctx, :power_on do
        :ready ->
          assert_payload do
            data.passengers ~> ^initial_passengers
          end
      end

      assert_transition ctx, :open_doors do
        :open ->
          assert_payload do
          end
      end

      assert_transition ctx, {:close_doors, %{passengers_entered: 5, passengers_exited: 0}} do
        :ready ->
          assert_payload do
            data.passengers ~> 5
          end
      end

      assert_transition ctx, :move do
        :moving ->
          assert_payload do
          end
      end

      assert_transition ctx, :stop do
        :ready ->
          assert_payload do
          end
      end

      assert_transition ctx, :power_off do
        :ready ->
          assert_payload do
          end
      end
    end
  end
end
