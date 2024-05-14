defmodule SimpleBank do
  @moduledoc """
  SimpleBank keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias SimpleBank.User.Create, as: UserCreate
  alias SimpleBank.User.Read, as: UserRead
  alias SimpleBank.User.Update, as: UserUpdate
  alias SimpleBank.User.Delete, as: UserDelete

  defdelegate create_user(params), to: UserCreate, as: :call
  defdelegate get_users, to: UserRead, as: :get_all
  defdelegate get_user_by_name(user_name), to: UserRead, as: :get_by_name
  defdelegate get_user_by_id(id), to: UserRead, as: :get_by_id
  defdelegate update_user(params), to: UserUpdate, as: :call
  defdelegate delete_user(id), to: UserDelete, as: :call

  alias SimpleBank.Account.Create, as: AccountCreate
  alias SimpleBank.Account.Read, as: AccountRead
  alias SimpleBank.Account.Update, as: AccountUpdate
  alias SimpleBank.Account.Delete, as: AccountDelete

  defdelegate create_account(params), to: AccountCreate, as: :call
  defdelegate get_accounts, to: AccountRead, as: :get_all
  defdelegate get_accounts_by_user_id(user_id), to: AccountRead, as: :get_by_user_id
  defdelegate get_account_by_id(id), to: AccountRead, as: :get_by_id
  defdelegate get_account_by_number(number), to: AccountRead, as: :get_by_number
  defdelegate update_account(params), to: AccountUpdate, as: :call
  defdelegate delete_account(id), to: AccountDelete, as: :call

  alias SimpleBank.Transaction.Create, as: TransactionCreate
  alias SimpleBank.Transaction.Read, as: TransactionRead
  alias SimpleBank.Transaction.Update, as: TransactionUpdate

  defdelegate create_transaction(params), to: TransactionCreate, as: :call
  defdelegate get_transaction_by_id(id), to: TransactionRead, as: :get_by_id
  defdelegate update_transaction(params), to: TransactionUpdate, as: :call
end
