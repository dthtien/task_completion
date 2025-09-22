class Task
  attr_reader :id, :status, :parent_id

  @@all_tasks = {}

  def initialize(id, status, parent_id = nil)
    @id = id
    @status = status
    @parent_id = parent_id
    @@all_tasks[id] = self
  end

  def children
    @@all_tasks.values.select { |task| task.parent_id == @id }
  end

  def subtree_stats(visited = [])
    infinite_loop_detected!(visited)
    visited << @id

    total = 1
    closed = 0
    inreview = 0

    closed += 1 if closed?
    inreview += 1 if inreview?

    children.each do |child|
      child_stats = child.subtree_stats(visited)
      total += child_stats[:total].to_i
      closed += child_stats[:closed].to_i
      inreview += child_stats[:inreview].to_i
    end

    open = total - closed - inreview

    { total:, closed:, inreview:, open: }
  end

  def completion_percentage
    stats = subtree_stats
    total = stats[:total]

    p_closed = (stats[:closed].to_f / total) * 100
    p_closed.round(2)
  end

  def inreview?
    @status == 'inreview'
  end

  def closed?
    @status == 'closed'
  end

  def open?
    @status == 'open'
  end

  private

  def infinite_loop_detected!(visited)
    return unless visited.include?(@id)

    raise "Infinite loop detected: circular dependency involving task '#{@id}'"
  end

  class << self
    def build_from_array(tasks_data)
      @@all_tasks = {}
      tasks_data.each do |task_id, status, parent_id|
        new(task_id, status, parent_id)
      end
      validate_no_cycles!
    end

    # For testing purposes - build without validation
    def build_from_array_without_validation(tasks_data)
      @@all_tasks = {}
      tasks_data.each do |task_id, status, parent_id|
        new(task_id, status, parent_id)
      end
    end

    def cycles?
      @@all_tasks.each do |_task_id, task|
        visited = []

        return true if check_for_cycles(task, visited, [])
      end

      false
    end

    def find_cycles
      cycles = []
      @@all_tasks.each do |_task_id, task|
        visited = Set.new
        path = []
        cycle = find_cycle_path(task, visited, path)
        cycles << cycle if cycle
      end
      cycles.uniq
    end

    def validate_no_cycles!
      cycles = find_cycles
      return unless cycles.any?

      cycle_details = cycles.map { |cycle| cycle.join(' -> ') }.join(', ')
      raise "Circular dependency detected: #{cycle_details}"
    end

    def completion_percentages
      result = {}
      @@all_tasks.each do |task_id, task|
        result[task_id] = task.completion_percentage
      end
      result
    end

    def all
      @@all_tasks.values
    end

    def find(id)
      @@all_tasks[id]
    end

    def reset
      @@all_tasks = {}
    end

    private

    def check_for_cycles(task, visited, path)
      return true if visited.include?(task.id)

      visited << task.id
      path << task.id

      task.children.each do |child|
        return true if check_for_cycles(child, visited, path)
      end

      path.pop
      false
    end

    def find_cycle_path(task, visited, path)
      if visited.include?(task.id)
        cycle_start = path.index(task.id)

        return path[cycle_start..] + [task.id] if cycle_start

        return nil
      end

      visited.add(task.id)
      path << task.id

      task.children.each do |child|
        cycle = find_cycle_path(child, visited, path)
        return cycle if cycle
      end

      path.pop
      nil
    end
  end
end
