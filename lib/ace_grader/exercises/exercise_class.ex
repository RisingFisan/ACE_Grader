defmodule AceGrader.Exercises.ExerciseClass do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "exercises_classes" do
    belongs_to :exercise, AceGrader.Exercises.Exercise, primary_key: true
    belongs_to :class, AceGrader.Classes.Class, primary_key: true
  end

  def changeset(exercise_class, attrs) do
    exercise_class
    |> cast(attrs, [:exercise_id, :class_id])
    |> unique_constraint([:exercise_id, :class_id])
  end
end
