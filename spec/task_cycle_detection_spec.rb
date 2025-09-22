require_relative 'spec_helper'

RSpec.describe Task do
  describe 'Cycle Detection' do
    after { Task.reset }

    describe '.cycles?' do
      context 'when there are no cycles' do
        context 'with a simple linear hierarchy' do
          before do
            Task.build_from_array_without_validation([
              ['task_001', 'open', nil],
              ['task_002', 'open', 'task_001'],
              ['task_003', 'closed', 'task_002']
            ])
          end
          it do
            expect(Task.cycles?).to be false
          end
        end

        context 'with a tree hierachy' do
          before do
            Task.build_from_array_without_validation([
              ['root', 'open', nil],
              ['child1', 'open', 'root'],
              ['child2', 'closed', 'root'],
              ['grandchild', 'open', 'child1']
            ])
          end

          it do
            expect(Task.cycles?).to be false
          end
        end

        context 'with disconnected tasks' do
          before do
            Task.build_from_array_without_validation([
              ['task_001', 'open', nil],
              ['task_002', 'closed', nil],
              ['task_003', 'open', nil]
            ])
          end
          it do
            expect(Task.cycles?).to be false
          end
        end
      end
    end

    context 'when there are cycles' do
      context 'with self-referencing tasks' do
        before do
          Task.build_from_array_without_validation([
            ['task_001', 'open', 'task_001']
          ])
        end
        it do
          expect(Task.cycles?).to be true
        end
      end

      context 'with multiple branches' do
        before do
          Task.build_from_array_without_validation([
            ['root', 'open', 'back_to_root'],
            ['branch1', 'open', 'root'],
            ['cycle_start', 'open', 'branch1'],
            ['cycle_end', 'open', 'cycle_start'],
            ['back_to_root', 'open', 'cycle_end']
          ])
        end

        it do
          expect(Task.cycles?).to be true
        end
      end
    end

    describe '.find_cycles' do
      context 'when there are no cycles' do
        before do
          Task.build_from_array_without_validation([
            ['task_001', 'open', nil],
            ['task_002', 'open', 'task_001']
          ])
        end
        it do
          expect(Task.find_cycles).to be_empty
        end
      end

      context 'when there are cycles' do
        it 'returns the cycle path for a simple 2-task cycle' do
          Task.build_from_array_without_validation([
            ['task_001', 'open', 'task_002'],
            ['task_002', 'open', 'task_001']
          ])

          cycles = Task.find_cycles
          expect(cycles).not_to be_empty
          expect(cycles.first).to include('task_001', 'task_002')
        end

        it 'returns the cycle path for a 3-task cycle' do
          Task.build_from_array_without_validation([
            ['task_A', 'open', 'task_C'],
            ['task_B', 'open', 'task_A'],
            ['task_C', 'open', 'task_B']
          ])

          cycles = Task.find_cycles
          expect(cycles).not_to be_empty
          expect(cycles.first).to include('task_A', 'task_B', 'task_C')
        end

        it 'returns the cycle path for a self-referencing task' do
          Task.build_from_array_without_validation([
            ['task_001', 'open', 'task_001']
          ])

          cycles = Task.find_cycles
          expect(cycles).not_to be_empty
          expect(cycles.first).to eq(['task_001', 'task_001'])
        end

        it 'returns multiple cycles when they exist' do
          Task.build_from_array_without_validation([
            ['cycle1_a', 'open', 'cycle1_b'],
            ['cycle1_b', 'open', 'cycle1_a'],
            ['cycle2_x', 'open', 'cycle2_y'],
            ['cycle2_y', 'open', 'cycle2_x']
          ])

          cycles = Task.find_cycles
          expect(cycles.length).to be >= 2
        end
      end
    end

    describe '.validate_no_cycles!' do
      context 'when there are no cycles' do
        it 'does not raise an error' do
          Task.build_from_array_without_validation([
            ['task_001', 'open', nil],
            ['task_002', 'open', 'task_001']
          ])

          expect { Task.validate_no_cycles! }.not_to raise_error
        end
      end

      context 'when there are cycles' do
        it 'raises an error with cycle details for simple cycle' do
          Task.build_from_array_without_validation([
            ['task_001', 'open', 'task_002'],
            ['task_002', 'open', 'task_001']
          ])

          expect { Task.validate_no_cycles! }.to raise_error(/Circular dependency detected/)
        end

        it 'raises an error with cycle details for complex cycle' do
          Task.build_from_array_without_validation([
            ['task_A', 'open', 'task_C'],
            ['task_B', 'open', 'task_A'],
            ['task_C', 'open', 'task_B']
          ])

          expect { Task.validate_no_cycles! }.to raise_error(/Circular dependency detected/)
        end

        it 'raises an error for self-referencing task' do
          Task.build_from_array_without_validation([
            ['task_001', 'open', 'task_001']
          ])

          expect { Task.validate_no_cycles! }.to raise_error(/Circular dependency detected/)
        end

        it 'includes the cycle path in the error message' do
          Task.build_from_array_without_validation([
            ['task_001', 'open', 'task_002'],
            ['task_002', 'open', 'task_001']
          ])

          expect { Task.validate_no_cycles! }.to raise_error(/task_001.*task_002.*task_001/)
        end
      end
    end

    describe 'integration with existing functionality' do
      it 'prevents infinite loops in subtree_stats' do
        expect {
          Task.build_from_array([
            ['task_001', 'open', 'task_002'],
            ['task_002', 'open', 'task_001']
          ])
        }.to raise_error(/Circular dependency detected/)
      end

      it 'allows normal operation when no cycles exist' do
        Task.build_from_array([
          ['task_001', 'open', nil],
          ['task_002', 'open', 'task_001'],
          ['task_003', 'closed', 'task_002']
        ])

        # This should work without issues
        expect(Task.completion_percentages).to be_a(Hash)
        expect(Task.completion_percentages.keys).to include('task_001', 'task_002', 'task_003')
      end
    end
  end
end
