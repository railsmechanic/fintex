defmodule FinTex.Data.AccountHandler do
  @moduledoc false

  alias FinTex.Model.Account

  @spec to_accounts_map(Enumerable.t) :: map
  def to_accounts_map(accounts) do
    accounts |> Map.new(fn account -> {Account.key(account), account} end)
  end


  @spec to_list(map) :: Enumerable.t
  def to_list(accounts) do
    accounts
    |> Map.values
    |> Enum.sort(fn account1, account2 ->
        account1 |> Account.key |> String.length <= account2 |> Account.key |> String.length &&
        account1 |> Account.key <= account2 |> Account.key
      end)
  end


  @spec find_account(map, Account.t) :: Account.t | nil
  def find_account(accounts, account = %Account{}) do
    result = accounts |> Map.get(account |> Account.key)
    case result do
      nil -> do_find_account(accounts, account)
      _ -> result
    end
  end


  defp do_find_account(accounts, account) do
    accounts
    |> Enum.reduce(nil, fn({_, value}, acc) -> find(value, account, acc) end)
  end


  defp find(
    %Account{iban: iban} = account,
    %Account{iban: iban},
    _
  ) when iban != nil
  do
    account
  end


  defp find(
    %Account{account_number: account_number, subaccount_id: subaccount_id} = account,
    %Account{account_number: account_number, subaccount_id: subaccount_id},
    _
  ) when account_number != nil
  do
    account
  end


  defp find(_, _, acc), do: acc
end
