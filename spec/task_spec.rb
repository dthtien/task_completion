require_relative 'spec_helper'

RSpec.describe Task do
  after { Task.reset }

  describe 'Instance Methods' do
    let!(:parent_task) { Task.new('1', 'open') }
    let!(:child_task1) { Task.new('2', 'closed', '1') }
    let!(:child_task2) { Task.new('3', 'open', '1') }
    let!(:unrelated_task) { Task.new('4', 'closed') }

    describe '#children' do
      context 'when there are child tasks' do
        it do
          expect(parent_task.children).to contain_exactly(child_task1, child_task2)
        end
      end

      context 'when there are no child tasks' do
        it do
          expect(unrelated_task.children).to be_empty
        end
      end
    end

    describe '#subtree_stats' do
      let!(:grandchild_task) { Task.new('4', 'closed', '2') }

      context 'with nested children' do
        let(:stats) { parent_task.subtree_stats }

        it { expect(stats).to include({ total: 4, closed: 2 }) }
      end

      context 'without children' do
        let(:stats) { unrelated_task.subtree_stats }
        it { expect(stats).to include({ total: 1, closed: 1 }) }
      end

      context 'with one level of children' do
        let(:stats) { child_task1.subtree_stats }
        it { expect(stats).to include({ total: 2, closed: 2 }) }
      end
    end

    describe '#completion_percentage' do
      context 'with mixed status children' do
        it do
          expect(parent_task.completion_percentage).to eq(33.33)
        end
      end

      context 'with all children closed' do
        let!(:grandchild_task) { Task.new('4', 'closed', '2') }

        it do
          expect(child_task1.completion_percentage).to eq(100.0)
        end
      end

      context 'with all children open' do
        let!(:grandchild_task) { Task.new('4', 'open', '3') }
        it do
          expect(child_task2.completion_percentage).to eq(0.0)
        end
      end

      context 'with no children' do
        context 'and closed status' do
          it do
            expect(unrelated_task.completion_percentage).to eq(100.0)
          end
        end

        context 'and open status' do
          let(:open_task) { Task.new('5', 'open') }
          it do
            expect(open_task.completion_percentage).to eq(0.0)
          end
        end
      end
    end

    describe '#closed?' do
      context 'when task is closed' do
        it do
          expect(child_task2.closed?).to be_falsey
        end
      end

      context 'when task is open' do
        it do
          expect(child_task1.closed?).to be_truthy
        end
      end
    end

    describe '#open?' do
      context 'when task is closed' do
        it do
          expect(child_task1.open?).to be_falsey
        end
      end

      context 'when task is open' do
        it do
          expect(child_task2.open?).to be_truthy
        end
      end
    end
  end

  describe 'Class Methods' do
    let(:tasks_data) do
      [
        ['task_001', 'open', nil],
        ['task_002', 'open', 'task_001'],
        ['task_003', 'closed', 'task_002']
      ]
    end

    before do
      Task.build_from_array(tasks_data)
    end

    describe '.build_from_array' do
      it do
        expect(Task.all.map(&:id)).to contain_exactly('task_001', 'task_002', 'task_003')
      end
    end

    describe '.completion_percentages' do
      it do
        expected_percentages = {
          'task_001' => 33.33,
          'task_002' => 50.0,
          'task_003' => 100.0
        }
        expect(Task.completion_percentages).to eq(expected_percentages)
      end
    end

    describe '.find' do
      context 'when task exists' do
        let(:task) { Task.find('task_001') }

        it do
          expect(task.id).to eq('task_001')
          expect(task).to be_open
        end
      end

      context 'when task does not exist' do
        let(:task) { Task.find('non_existent_task') }

        it do
          expect(task).to be_nil
        end
      end
    end

    describe '.all' do
      it do
        expect(Task.all).to have_attributes(size: 3)
      end
    end

    describe '.reset' do
      it do
        expect(Task.all).not_to be_empty
        Task.reset
        expect(Task.all).to be_empty
      end
    end
  end
end
