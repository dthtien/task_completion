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

  def subtree_stats
    total = 1
    closed = closed? ? 1 : 0

    children.each do |child|
      child_stats = child.subtree_stats
      total += child_stats[:total]
      closed += child_stats[:closed]
    end

    { total: total, closed: closed }
  end

  def completion_percentage
    stats = subtree_stats
    (stats[:closed].to_f / stats[:total] * 100).round(2)
  end

  def closed?
    @status == 'closed'
  end

  def open?
    @status == 'open'
  end

  class << self
    def build_from_array(tasks_data)
      @@all_tasks = {}
      tasks_data.each do |task_id, status, parent_id|
        new(task_id, status, parent_id)
      end
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
  end
end
