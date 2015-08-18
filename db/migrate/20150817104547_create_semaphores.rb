class CreateSemaphores < ActiveRecord::Migration
  def up
    create_table :semaphores do |t|
      t.integer :slave_id
      t.integer :execution_type
      t.timestamps null: false
    end

    add_index :semaphores, :execution_type, unique: true
  end

  def down
    remove_index :semaphores, :execution_type

    drop_table :semaphores
  end
end
