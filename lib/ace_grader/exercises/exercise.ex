defmodule AceGrader.Exercises.Languages do
  def supported_languages do
    [:c, :haskell]
  end
end

defmodule AceGrader.Exercises.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: [:id, :title, :description, :language, :author_id, :visibility, :test_file, :template, :tests, :parameters]}
  schema "exercises" do
    field :description, :string
    field :visibility, Ecto.Enum, values: [:public, :class, :private], default: :public
    field :title, :string
    field :language, Ecto.Enum, values: AceGrader.Exercises.Languages.supported_languages, default: :c

    field :test_file, :string
    field :template, :string
    field :testing_enabled, :boolean, default: false

    field :total_grade, :integer, virtual: true

    belongs_to :user, AceGrader.Accounts.User, foreign_key: :author_id

    has_many :submissions, AceGrader.Submissions.Submission
    has_many :tests, AceGrader.Exercises.Test, on_replace: :delete
    has_many :parameters, AceGrader.Exercises.Parameter, on_replace: :delete

    has_many :exercise_classes,
      AceGrader.Exercises.ExerciseClass,
      on_replace: :delete
    has_many :classes, through: [:exercise_classes, :class]

    timestamps()
  end

  @doc false
  def changeset(exercise, attrs) do
    tests = Map.get(attrs, "tests", %{})
    parameters = Map.get(attrs, "parameters", %{})
    graded_params = Map.filter(parameters, fn {_key, param} -> param["type"] == "graded" end)

    validate_grade = not Enum.any?(tests, fn {_key, test} -> test["grade"] == "" end) and not Enum.any?(graded_params, fn {_key, param} -> param["grade"] == "" end)

    attrs = if validate_grade and attrs != %{} do
      sum =
        Enum.reduce(tests, 0, fn {_key, tp}, acc -> acc + (if !tp["grade"] or tp["delete"] == "true", do: 0, else: String.to_integer(tp["grade"])) end)
        |> Kernel.+(Enum.reduce(graded_params, 0, fn {_key, gp}, acc -> acc + (if !gp["grade"] or gp["delete"] == "true", do: 0, else: String.to_integer(gp["grade"])) end))
      Map.put(attrs, "total_grade", sum)
    else
      attrs
    end

    exercise
    |> cast(attrs, [:title, :description, :visibility, :total_grade, :language, :author_id, :test_file, :template, :testing_enabled])
    |> validate_required([:title, :description, :language, :visibility, :testing_enabled])
    |> cast_assoc(:tests, sort_param: :tests_order, drop_param: :tests_delete)
    |> cast_assoc(:parameters, sort_param: :params_order, drop_param: :params_delete)
    |> cast_assoc(:exercise_classes)
    |> copy_test_positions()
    |> copy_param_positions()
    |> (& if validate_grade, do: validate_number(&1, :total_grade, equal_to: 100), else: &1).()
  end

  def changeset_duplicate(exercise, attrs) do
    exercise
    |> cast(attrs, [:title, :description, :visibility, :total_grade, :language, :author_id, :test_file, :template, :testing_enabled])
    |> validate_required([:title, :description, :language, :visibility, :testing_enabled])
    |> cast_assoc(:tests)
    |> cast_assoc(:parameters)
  end

  defp copy_test_positions(changeset) do
    if tests = Ecto.Changeset.get_change(changeset, :tests) do
      tests
      |> Enum.filter(fn changeset -> changeset.action != :replace end)
      |> Enum.with_index(fn test, index ->
        Ecto.Changeset.put_change(test, :position, index)
      end)
      |> then(&Ecto.Changeset.put_change(changeset, :tests, &1))
    else
      changeset
    end
  end

  defp copy_param_positions(changeset) do
    if parameters = Ecto.Changeset.get_change(changeset, :parameters) do
      parameters
      |> Enum.filter(fn changeset -> changeset.action != :replace end)
      |> Enum.with_index(fn parameter, index ->
        Ecto.Changeset.put_change(parameter, :position, index)
      end)
      |> then(&Ecto.Changeset.put_change(changeset, :parameters, &1))
    else
      changeset
    end
  end

  def is_owner?(exercise, user) do
    user && exercise.author_id == user.id
  end
end
