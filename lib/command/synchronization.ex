defmodule FinTex.Command.Synchronization do
  @moduledoc false

  alias FinTex.Command.AbstractCommand
  alias FinTex.Command.Sequencer
  alias FinTex.Model.Dialog
  alias FinTex.Segment.HKEND
  alias FinTex.Segment.HNHBK
  alias FinTex.Segment.HNHBS
  alias FinTex.Segment.HNSHA
  alias FinTex.Segment.HNSHK
  alias FinTex.Service.Accounts
  alias FinTex.Service.SEPAInfo


  use AbstractCommand

  def synchronize(bank, client_system_id, tan_scheme_sec_func, credentials, options) when is_list(options) do
    seq = Sequencer.new(client_system_id, bank, credentials, options)

    if tan_scheme_sec_func != nil do
      seq = seq |> Sequencer.reset(tan_scheme_sec_func)
    end

    {seq, accounts} = {seq, %{}}
    |> Accounts.update_accounts
    |> SEPAInfo.update_accounts

    {seq, accounts}
  end


  def terminate(seq) do
    request_segments = [
      %HNHBK{},
      %HNSHK{},
      %HKEND{},
      %HNSHA{},
      %HNHBS{}
    ]
    {:ok, _} = seq |> Sequencer.call_http(request_segments)
  end
end
