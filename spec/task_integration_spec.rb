require_relative 'spec_helper'
# Test data https://github.com/visibuild/visibuild-coding-challenges/blob/master/task-completion/task-completion.data.md

RSpec.describe Task do
  describe 'Integration Tests' do
    after { Task.reset }

    shared_examples "task percentages" do |tasks_data, expected_percentages|
      before do
        Task.build_from_array(tasks_data)
      end

      it "returns the correct completion percentages" do
        percentages = Task.completion_percentages
        expect(percentages).to eq(expected_percentages)
      end
    end

    context '1' do
      include_examples "task percentages",
        [
          ["task_001", "open", nil],
          ["task_002", "open", "task_001"],
          ["task_003", "closed", "task_002"],
          ["task_004", "closed", "task_001"],
          ["task_005", "closed", "task_004"]
        ],
        {
          "task_001" => 60.0,
          "task_002" => 50.0,
          "task_003" => 100.0,
          "task_004" => 100.0,
          "task_005" => 100.0
        }
    end

    context '2' do
      include_examples "task percentages",
        [
          ["task_100", "closed", nil],
          ["task_101", "closed", "task_100"],
          ["task_102", "closed", "task_100"],
          ["task_103", "closed", "task_101"]
        ],
        {
          "task_100" => 100.0,
          "task_101" => 100.0,
          "task_102" => 100.0,
          "task_103" => 100.0
        }
    end

    context '3' do
      include_examples "task percentages",
        [
          ["task_200", "open", nil],
          ["task_201", "open", "task_200"],
          ["task_202", "closed", "task_201"],
          ["task_203", "open", "task_202"],
          ["task_204", "closed", "task_203"],
          ["task_205", "open", "task_200"],
          ["task_206", "closed", "task_205"]
        ],
        {
          "task_200" => 42.86,
          "task_201" => 50.0,
          "task_202" => 66.67,
          "task_203" => 50.0,
          "task_204" => 100.0,
          "task_205" => 50.0,
          "task_206" => 100.0
        }
    end

    context '4' do
      include_examples "task percentages",
        [
          ["task_300", "open", nil],
          ["task_301", "closed", "task_300"],
          ["task_302", "open", "task_300"],
          ["task_303", "closed", "task_300"],
          ["task_304", "closed", "task_300"],
          ["task_305", "open", "task_300"]
        ],
        {
          "task_300" => 50.0,
          "task_301" => 100.0,
          "task_302" => 0.0,
          "task_303" => 100.0,
          "task_304" => 100.0,
          "task_305" => 0.0
        }
    end
  end

  context 'with loop' do
    let(:tasks_data) do
      [
        ["task_001", "open", nil],
        ["task_002", "open", "task_003"],
        ["task_003", "closed", "task_002"]
      ]
    end

    before do
      Task.build_from_array_without_validation(tasks_data)
    end

    it do
      expect { Task.completion_percentages }.to raise_error(RuntimeError, /Infinite loop detected/)
    end
  end
end
